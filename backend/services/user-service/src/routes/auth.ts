import express from 'express';
import { body } from 'express-validator';
import {
  register,
  login,
  logout,
  refreshToken,
  verifyEmail,
  resendVerification,
  requestPasswordReset,
  resetPassword,
  changePassword,
  loginWithSocial,
} from '../controllers/authController';
import { validateRequest } from '../middleware/validation';
import { authMiddleware } from '../middleware/auth';

const router = express.Router();

// Registration
router.post(
  '/register',
  [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email is required'),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
      .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'),
    body('firstName')
      .optional()
      .isLength({ min: 2, max: 50 })
      .withMessage('First name must be between 2 and 50 characters'),
    body('lastName')
      .optional()
      .isLength({ min: 2, max: 50 })
      .withMessage('Last name must be between 2 and 50 characters'),
    body('acceptTerms')
      .equals('true')
      .withMessage('You must accept the terms and conditions'),
  ],
  validateRequest,
  register
);

// Login
router.post(
  '/login',
  [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email is required'),
    body('password')
      .notEmpty()
      .withMessage('Password is required'),
  ],
  validateRequest,
  login
);

// Social login (Google, Facebook, Apple)
router.post(
  '/social/:provider',
  [
    body('accessToken')
      .notEmpty()
      .withMessage('Access token is required'),
    body('profile')
      .isObject()
      .withMessage('User profile is required'),
  ],
  validateRequest,
  loginWithSocial
);

// Refresh JWT token
router.post(
  '/refresh',
  [
    body('refreshToken')
      .notEmpty()
      .withMessage('Refresh token is required'),
  ],
  validateRequest,
  refreshToken
);

// Logout (requires authentication)
router.post('/logout', authMiddleware, logout);

// Logout from all devices
router.post('/logout-all', authMiddleware, logout);

// Email verification
router.post(
  '/verify-email',
  [
    body('token')
      .notEmpty()
      .withMessage('Verification token is required'),
  ],
  validateRequest,
  verifyEmail
);

// Resend email verification
router.post(
  '/resend-verification',
  [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email is required'),
  ],
  validateRequest,
  resendVerification
);

// Request password reset
router.post(
  '/forgot-password',
  [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email is required'),
  ],
  validateRequest,
  requestPasswordReset
);

// Reset password with token
router.post(
  '/reset-password',
  [
    body('token')
      .notEmpty()
      .withMessage('Reset token is required'),
    body('newPassword')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
      .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'),
  ],
  validateRequest,
  resetPassword
);

// Change password (requires authentication)
router.post(
  '/change-password',
  authMiddleware,
  [
    body('currentPassword')
      .notEmpty()
      .withMessage('Current password is required'),
    body('newPassword')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
      .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'),
  ],
  validateRequest,
  changePassword
);

// Check authentication status
router.get('/me', authMiddleware, (req, res) => {
  res.json({
    success: true,
    data: {
      user: req.user,
    },
  });
});

// Validate token (for other services)
router.post(
  '/validate-token',
  [
    body('token')
      .notEmpty()
      .withMessage('Token is required'),
  ],
  validateRequest,
  async (req, res) => {
    try {
      // This endpoint will be used by the gateway to validate tokens
      // The actual validation logic will be in the controller
      res.json({
        success: true,
        message: 'Token validation endpoint - implementation pending',
      });
    } catch (error) {
      res.status(401).json({
        success: false,
        error: 'Invalid token',
        code: 'INVALID_TOKEN',
      });
    }
  }
);

export default router;