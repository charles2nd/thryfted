import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { PrismaClient } from '@prisma/client';
import { logger } from '../utils/logger';
import { 
  generateAccessToken, 
  generateRefreshToken, 
  verifyRefreshToken 
} from '../services/tokenService';
import { 
  sendVerificationEmail, 
  sendPasswordResetEmail 
} from '../services/emailService';
import { 
  validateSocialLogin, 
  getSocialUserInfo 
} from '../services/socialAuthService';
import { createUserAuditLog } from '../services/auditService';

const prisma = new PrismaClient();

// Register new user
export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password, firstName, lastName, acceptTerms } = req.body;
    
    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });
    
    if (existingUser) {
      res.status(409).json({
        success: false,
        error: 'User with this email already exists',
        code: 'USER_ALREADY_EXISTS',
      });
      return;
    }
    
    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    // Generate email verification token
    const emailVerificationToken = uuidv4();
    
    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        firstName,
        lastName,
        displayName: firstName && lastName ? `${firstName} ${lastName}` : firstName || email.split('@')[0],
        emailVerificationToken,
        preferences: {
          create: {
            // Default preferences
            emailNotifications: true,
            pushNotifications: true,
            notifyNewMessages: true,
            notifyOffers: true,
            notifyOrderUpdates: true,
          },
        },
      },
      include: {
        preferences: true,
      },
    });
    
    // Send verification email
    try {
      await sendVerificationEmail(email, emailVerificationToken);
      logger.info(`Verification email sent to ${email}`);
    } catch (emailError) {
      logger.error('Failed to send verification email:', emailError);
      // Don't fail registration if email fails
    }
    
    // Generate tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id);
    
    // Create user session
    await prisma.userSession.create({
      data: {
        userId: user.id,
        token: refreshToken,
        deviceType: req.headers['x-device-type'] as any || 'UNKNOWN',
        deviceName: req.headers['x-device-name'] as string,
        ipAddress: req.ip,
        userAgent: req.get('User-Agent'),
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      },
    });
    
    // Log registration
    await createUserAuditLog(user.id, 'REGISTRATION', {
      email,
      method: 'email',
    }, req.ip, req.get('User-Agent'));
    
    logger.info(`User registered successfully: ${email} (${user.id})`);
    
    // Return user data without password
    const { password: _, emailVerificationToken: __, ...userResponse } = user;
    
    res.status(201).json({
      success: true,
      data: {
        user: userResponse,
        tokens: {
          accessToken,
          refreshToken,
          expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24 hours
        },
      },
      message: 'Registration successful. Please check your email for verification.',
    });
  } catch (error) {
    logger.error('Registration error:', error);
    res.status(500).json({
      success: false,
      error: 'Registration failed',
      code: 'REGISTRATION_ERROR',
    });
  }
};

// Login user
export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password, rememberMe = false } = req.body;
    
    // Find user by email
    const user = await prisma.user.findUnique({
      where: { email },
      include: {
        preferences: true,
      },
    });
    
    if (!user) {
      // Log failed login attempt
      await createUserAuditLog(null, 'LOGIN_FAILED', {
        email,
        reason: 'user_not_found',
      }, req.ip, req.get('User-Agent'), false);
      
      res.status(401).json({
        success: false,
        error: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      });
      return;
    }
    
    // Check if user is active
    if (!user.isActive || user.isSuspended) {
      await createUserAuditLog(user.id, 'LOGIN_BLOCKED', {
        email,
        reason: user.isSuspended ? 'suspended' : 'inactive',
      }, req.ip, req.get('User-Agent'), false);
      
      res.status(403).json({
        success: false,
        error: user.isSuspended ? 'Account suspended' : 'Account inactive',
        code: user.isSuspended ? 'ACCOUNT_SUSPENDED' : 'ACCOUNT_INACTIVE',
      });
      return;
    }
    
    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    
    if (!isPasswordValid) {
      await createUserAuditLog(user.id, 'LOGIN_FAILED', {
        email,
        reason: 'invalid_password',
      }, req.ip, req.get('User-Agent'), false);
      
      res.status(401).json({
        success: false,
        error: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      });
      return;
    }
    
    // Generate tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id);
    
    // Create/update user session
    const expiresAt = new Date(Date.now() + (rememberMe ? 30 : 7) * 24 * 60 * 60 * 1000); // 30 days if remember me, 7 days otherwise
    
    await prisma.userSession.create({
      data: {
        userId: user.id,
        token: refreshToken,
        deviceType: req.headers['x-device-type'] as any || 'UNKNOWN',
        deviceName: req.headers['x-device-name'] as string,
        ipAddress: req.ip,
        userAgent: req.get('User-Agent'),
        expiresAt,
      },
    });
    
    // Update last login
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });
    
    // Log successful login
    await createUserAuditLog(user.id, 'LOGIN_SUCCESS', {
      email,
      rememberMe,
    }, req.ip, req.get('User-Agent'));
    
    logger.info(`User logged in successfully: ${email} (${user.id})`);
    
    // Return user data without password
    const { password: _, emailVerificationToken: __, ...userResponse } = user;
    
    res.json({
      success: true,
      data: {
        user: userResponse,
        tokens: {
          accessToken,
          refreshToken,
          expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24 hours
        },
      },
      message: 'Login successful',
    });
  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Login failed',
      code: 'LOGIN_ERROR',
    });
  }
};

// Logout user
export const logout = async (req: Request, res: Response): Promise<void> => {
  try {
    const { refreshToken } = req.body;
    const userId = req.user?.id;
    
    if (!userId) {
      res.status(401).json({
        success: false,
        error: 'Authentication required',
        code: 'AUTH_REQUIRED',
      });
      return;
    }
    
    if (refreshToken) {
      // Logout from specific device
      await prisma.userSession.deleteMany({
        where: {
          userId,
          token: refreshToken,
        },
      });
    } else {
      // Logout from all devices
      await prisma.userSession.deleteMany({
        where: { userId },
      });
    }
    
    // Log logout
    await createUserAuditLog(userId, 'LOGOUT', {
      logoutType: refreshToken ? 'single_device' : 'all_devices',
    }, req.ip, req.get('User-Agent'));
    
    logger.info(`User logged out: ${userId}`);
    
    res.json({
      success: true,
      message: 'Logout successful',
    });
  } catch (error) {
    logger.error('Logout error:', error);
    res.status(500).json({
      success: false,
      error: 'Logout failed',
      code: 'LOGOUT_ERROR',
    });
  }
};

// Refresh JWT token
export const refreshToken = async (req: Request, res: Response): Promise<void> => {
  try {
    const { refreshToken: token } = req.body;
    
    // Verify refresh token
    const payload = verifyRefreshToken(token);
    
    if (!payload) {
      res.status(401).json({
        success: false,
        error: 'Invalid refresh token',
        code: 'INVALID_REFRESH_TOKEN',
      });
      return;
    }
    
    // Check if session exists and is active
    const session = await prisma.userSession.findFirst({
      where: {
        token,
        isActive: true,
        expiresAt: { gt: new Date() },
      },
      include: {
        user: {
          include: {
            preferences: true,
          },
        },
      },
    });
    
    if (!session || !session.user.isActive) {
      res.status(401).json({
        success: false,
        error: 'Session expired or invalid',
        code: 'SESSION_EXPIRED',
      });
      return;
    }
    
    // Generate new access token
    const accessToken = generateAccessToken(session.user);
    
    // Update session last used
    await prisma.userSession.update({
      where: { id: session.id },
      data: { lastUsedAt: new Date() },
    });
    
    logger.info(`Token refreshed for user: ${session.user.id}`);
    
    res.json({
      success: true,
      data: {
        tokens: {
          accessToken,
          refreshToken: token, // Keep same refresh token
          expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24 hours
        },
      },
    });
  } catch (error) {
    logger.error('Token refresh error:', error);
    res.status(401).json({
      success: false,
      error: 'Token refresh failed',
      code: 'TOKEN_REFRESH_ERROR',
    });
  }
};

// Verify email
export const verifyEmail = async (req: Request, res: Response): Promise<void> => {
  try {
    const { token } = req.body;
    
    // Find user with verification token
    const user = await prisma.user.findFirst({
      where: {
        emailVerificationToken: token,
        isEmailVerified: false,
      },
    });
    
    if (!user) {
      res.status(400).json({
        success: false,
        error: 'Invalid or expired verification token',
        code: 'INVALID_VERIFICATION_TOKEN',
      });
      return;
    }
    
    // Update user as verified
    await prisma.user.update({
      where: { id: user.id },
      data: {
        isEmailVerified: true,
        emailVerificationToken: null,
      },
    });
    
    // Log verification
    await createUserAuditLog(user.id, 'EMAIL_VERIFIED', {
      email: user.email,
    });
    
    logger.info(`Email verified for user: ${user.email} (${user.id})`);
    
    res.json({
      success: true,
      message: 'Email verified successfully',
    });
  } catch (error) {
    logger.error('Email verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Email verification failed',
      code: 'EMAIL_VERIFICATION_ERROR',
    });
  }
};

// Resend email verification
export const resendVerification = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email } = req.body;
    
    const user = await prisma.user.findUnique({
      where: { email },
    });
    
    if (!user) {
      // Don't reveal if user exists
      res.json({
        success: true,
        message: 'If an account with this email exists, a verification email has been sent.',
      });
      return;
    }
    
    if (user.isEmailVerified) {
      res.status(400).json({
        success: false,
        error: 'Email is already verified',
        code: 'EMAIL_ALREADY_VERIFIED',
      });
      return;
    }
    
    // Generate new verification token
    const emailVerificationToken = uuidv4();
    
    await prisma.user.update({
      where: { id: user.id },
      data: { emailVerificationToken },
    });
    
    // Send verification email
    await sendVerificationEmail(email, emailVerificationToken);
    
    logger.info(`Verification email resent to: ${email}`);
    
    res.json({
      success: true,
      message: 'Verification email sent',
    });
  } catch (error) {
    logger.error('Resend verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to send verification email',
      code: 'RESEND_VERIFICATION_ERROR',
    });
  }
};

// Request password reset
export const requestPasswordReset = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email } = req.body;
    
    const user = await prisma.user.findUnique({
      where: { email },
    });
    
    if (!user) {
      // Don't reveal if user exists
      res.json({
        success: true,
        message: 'If an account with this email exists, a password reset email has been sent.',
      });
      return;
    }
    
    // Generate password reset token
    const resetToken = uuidv4();
    const resetExpiry = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    
    await prisma.user.update({
      where: { id: user.id },
      data: {
        passwordResetToken: resetToken,
        passwordResetExpiry: resetExpiry,
      },
    });
    
    // Send password reset email
    await sendPasswordResetEmail(email, resetToken);
    
    // Log password reset request
    await createUserAuditLog(user.id, 'PASSWORD_RESET_REQUESTED', {
      email,
    }, req.ip, req.get('User-Agent'));
    
    logger.info(`Password reset requested for: ${email}`);
    
    res.json({
      success: true,
      message: 'If an account with this email exists, a password reset email has been sent.',
    });
  } catch (error) {
    logger.error('Password reset request error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to process password reset request',
      code: 'PASSWORD_RESET_REQUEST_ERROR',
    });
  }
};

// Reset password with token
export const resetPassword = async (req: Request, res: Response): Promise<void> => {
  try {
    const { token, newPassword } = req.body;
    
    // Find user with valid reset token
    const user = await prisma.user.findFirst({
      where: {
        passwordResetToken: token,
        passwordResetExpiry: { gt: new Date() },
      },
    });
    
    if (!user) {
      res.status(400).json({
        success: false,
        error: 'Invalid or expired reset token',
        code: 'INVALID_RESET_TOKEN',
      });
      return;
    }
    
    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 12);
    
    // Update password and clear reset token
    await prisma.user.update({
      where: { id: user.id },
      data: {
        password: hashedPassword,
        passwordResetToken: null,
        passwordResetExpiry: null,
      },
    });
    
    // Invalidate all user sessions (force re-login)
    await prisma.userSession.deleteMany({
      where: { userId: user.id },
    });
    
    // Log password reset
    await createUserAuditLog(user.id, 'PASSWORD_RESET_COMPLETED', {
      email: user.email,
    }, req.ip, req.get('User-Agent'));
    
    logger.info(`Password reset completed for: ${user.email} (${user.id})`);
    
    res.json({
      success: true,
      message: 'Password reset successful',
    });
  } catch (error) {
    logger.error('Password reset error:', error);
    res.status(500).json({
      success: false,
      error: 'Password reset failed',
      code: 'PASSWORD_RESET_ERROR',
    });
  }
};

// Change password (authenticated user)
export const changePassword = async (req: Request, res: Response): Promise<void> => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user?.id;
    
    if (!userId) {
      res.status(401).json({
        success: false,
        error: 'Authentication required',
        code: 'AUTH_REQUIRED',
      });
      return;
    }
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });
    
    if (!user) {
      res.status(404).json({
        success: false,
        error: 'User not found',
        code: 'USER_NOT_FOUND',
      });
      return;
    }
    
    // Verify current password
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
    
    if (!isCurrentPasswordValid) {
      res.status(400).json({
        success: false,
        error: 'Current password is incorrect',
        code: 'INVALID_CURRENT_PASSWORD',
      });
      return;
    }
    
    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 12);
    
    // Update password
    await prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });
    
    // Log password change
    await createUserAuditLog(userId, 'PASSWORD_CHANGED', {
      email: user.email,
    }, req.ip, req.get('User-Agent'));
    
    logger.info(`Password changed for user: ${user.email} (${userId})`);
    
    res.json({
      success: true,
      message: 'Password changed successfully',
    });
  } catch (error) {
    logger.error('Change password error:', error);
    res.status(500).json({
      success: false,
      error: 'Password change failed',
      code: 'PASSWORD_CHANGE_ERROR',
    });
  }
};

// Social login (Google, Facebook, Apple)
export const loginWithSocial = async (req: Request, res: Response): Promise<void> => {
  try {
    const { provider } = req.params;
    const { accessToken, profile } = req.body;
    
    // Validate social provider
    if (!['google', 'facebook', 'apple'].includes(provider)) {
      res.status(400).json({
        success: false,
        error: 'Unsupported social provider',
        code: 'INVALID_PROVIDER',
      });
      return;
    }
    
    // Validate social login token and get user info
    const socialUserInfo = await getSocialUserInfo(provider as any, accessToken);
    
    if (!socialUserInfo) {
      res.status(401).json({
        success: false,
        error: 'Invalid social login token',
        code: 'INVALID_SOCIAL_TOKEN',
      });
      return;
    }
    
    // Check if user exists with this email
    let user = await prisma.user.findUnique({
      where: { email: socialUserInfo.email },
      include: { preferences: true },
    });
    
    if (!user) {
      // Create new user from social login
      user = await prisma.user.create({
        data: {
          email: socialUserInfo.email,
          firstName: socialUserInfo.firstName,
          lastName: socialUserInfo.lastName,
          displayName: socialUserInfo.name || `${socialUserInfo.firstName} ${socialUserInfo.lastName}`.trim(),
          profilePicture: socialUserInfo.picture,
          password: await bcrypt.hash(uuidv4(), 12), // Random password
          isEmailVerified: true, // Trust social provider
          preferences: {
            create: {
              emailNotifications: true,
              pushNotifications: true,
              notifyNewMessages: true,
              notifyOffers: true,
              notifyOrderUpdates: true,
            },
          },
          socialLogins: {
            create: {
              provider: provider.toUpperCase() as any,
              providerId: socialUserInfo.id,
              email: socialUserInfo.email,
              name: socialUserInfo.name,
              picture: socialUserInfo.picture,
              accessToken,
            },
          },
        },
        include: { preferences: true },
      });
      
      logger.info(`New user created via ${provider}: ${user.email} (${user.id})`);
    } else {
      // Update or create social login entry
      await prisma.socialLogin.upsert({
        where: {
          userId_provider: {
            userId: user.id,
            provider: provider.toUpperCase() as any,
          },
        },
        update: {
          accessToken,
          name: socialUserInfo.name,
          picture: socialUserInfo.picture,
        },
        create: {
          userId: user.id,
          provider: provider.toUpperCase() as any,
          providerId: socialUserInfo.id,
          email: socialUserInfo.email,
          name: socialUserInfo.name,
          picture: socialUserInfo.picture,
          accessToken,
        },
      });
      
      // Update user's profile picture if not set
      if (!user.profilePicture && socialUserInfo.picture) {
        user = await prisma.user.update({
          where: { id: user.id },
          data: { profilePicture: socialUserInfo.picture },
          include: { preferences: true },
        });
      }
    }
    
    // Generate tokens
    const jwtAccessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id);
    
    // Create user session
    await prisma.userSession.create({
      data: {
        userId: user.id,
        token: refreshToken,
        deviceType: req.headers['x-device-type'] as any || 'UNKNOWN',
        deviceName: req.headers['x-device-name'] as string,
        ipAddress: req.ip,
        userAgent: req.get('User-Agent'),
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      },
    });
    
    // Update last login
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });
    
    // Log social login
    await createUserAuditLog(user.id, 'SOCIAL_LOGIN', {
      provider,
      email: user.email,
    }, req.ip, req.get('User-Agent'));
    
    logger.info(`User logged in via ${provider}: ${user.email} (${user.id})`);
    
    // Return user data without password
    const { password: _, emailVerificationToken: __, ...userResponse } = user;
    
    res.json({
      success: true,
      data: {
        user: userResponse,
        tokens: {
          accessToken: jwtAccessToken,
          refreshToken,
          expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        },
      },
      message: 'Social login successful',
    });
  } catch (error) {
    logger.error('Social login error:', error);
    res.status(500).json({
      success: false,
      error: 'Social login failed',
      code: 'SOCIAL_LOGIN_ERROR',
    });
  }
};