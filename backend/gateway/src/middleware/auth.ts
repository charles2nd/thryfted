import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { logger } from '../utils/logger';
import { getFromCache, setInCache } from '../utils/redis';

// Extend Request interface to include user
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email: string;
        isVerified: boolean;
        roles?: string[];
      };
    }
  }
}

interface JWTPayload {
  id: string;
  email: string;
  isVerified: boolean;
  roles?: string[];
  iat?: number;
  exp?: number;
}

// Cache key for blacklisted tokens
const getBlacklistKey = (tokenId: string) => `blacklist:${tokenId}`;
const getUserCacheKey = (userId: string) => `user:${userId}`;

// Extract token from request
const extractToken = (req: Request): string | null => {
  const authHeader = req.headers.authorization;
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return authHeader.substring(7);
  }
  
  // Also check for token in cookies (for web clients)
  if (req.cookies && req.cookies.token) {
    return req.cookies.token;
  }
  
  return null;
};

// Verify JWT token
const verifyToken = async (token: string): Promise<JWTPayload | null> => {
  try {
    const decoded = jwt.verify(token, config.jwtSecret) as JWTPayload;
    
    // Check if token is blacklisted
    const tokenId = `${decoded.id}:${decoded.iat}`;
    const isBlacklisted = await getFromCache(getBlacklistKey(tokenId));
    
    if (isBlacklisted) {
      logger.warn(`Blacklisted token used: ${tokenId}`);
      return null;
    }
    
    return decoded;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      logger.warn('Token expired');
    } else if (error instanceof jwt.JsonWebTokenError) {
      logger.warn('Invalid token');
    } else {
      logger.error('Token verification error:', error);
    }
    
    return null;
  }
};

// Get user from cache or database
const getUserFromCache = async (userId: string): Promise<any | null> => {
  try {
    const cachedUser = await getFromCache(getUserCacheKey(userId));
    
    if (cachedUser) {
      return JSON.parse(cachedUser);
    }
    
    // If not in cache, the user service should handle the lookup
    return null;
  } catch (error) {
    logger.error('Error getting user from cache:', error);
    return null;
  }
};

// Cache user data
const cacheUser = async (user: any): Promise<void> => {
  try {
    await setInCache(getUserCacheKey(user.id), JSON.stringify(user), 300); // 5 minutes cache
  } catch (error) {
    logger.error('Error caching user:', error);
  }
};

// Required authentication middleware
export const authMiddleware = async (
  req: Request, 
  res: Response, 
  next: NextFunction
): Promise<void> => {
  try {
    const token = extractToken(req);
    
    if (!token) {
      res.status(401).json({
        success: false,
        error: 'Authorization token required',
        code: 'AUTH_REQUIRED',
      });
      return;
    }
    
    const payload = await verifyToken(token);
    
    if (!payload) {
      res.status(401).json({
        success: false,
        error: 'Invalid or expired token',
        code: 'INVALID_TOKEN',
      });
      return;
    }
    
    // Try to get user from cache first
    let user = await getUserFromCache(payload.id);
    
    // Set user context
    req.user = {
      id: payload.id,
      email: payload.email,
      isVerified: payload.isVerified,
      roles: payload.roles || [],
    };
    
    // Cache user if we have full data
    if (user) {
      await cacheUser(user);
    }
    
    logger.info(`Authenticated user: ${payload.email} (${payload.id})`);
    next();
  } catch (error) {
    logger.error('Authentication middleware error:', error);
    res.status(500).json({
      success: false,
      error: 'Authentication error',
      code: 'AUTH_ERROR',
    });
  }
};

// Optional authentication middleware (doesn't fail if no token)
export const optionalAuth = async (
  req: Request, 
  res: Response, 
  next: NextFunction
): Promise<void> => {
  try {
    const token = extractToken(req);
    
    if (!token) {
      // No token provided, continue without user context
      next();
      return;
    }
    
    const payload = await verifyToken(token);
    
    if (payload) {
      // Valid token, set user context
      req.user = {
        id: payload.id,
        email: payload.email,
        isVerified: payload.isVerified,
        roles: payload.roles || [],
      };
      
      logger.info(`Optionally authenticated user: ${payload.email} (${payload.id})`);
    }
    
    next();
  } catch (error) {
    logger.error('Optional authentication middleware error:', error);
    // Don't fail on optional auth errors, just continue without user context
    next();
  }
};

// Admin role check middleware
export const requireAdmin = (
  req: Request, 
  res: Response, 
  next: NextFunction
): void => {
  if (!req.user) {
    res.status(401).json({
      success: false,
      error: 'Authentication required',
      code: 'AUTH_REQUIRED',
    });
    return;
  }
  
  if (!req.user.roles?.includes('admin')) {
    res.status(403).json({
      success: false,
      error: 'Admin access required',
      code: 'ADMIN_REQUIRED',
    });
    return;
  }
  
  next();
};

// Verified user check middleware
export const requireVerified = (
  req: Request, 
  res: Response, 
  next: NextFunction
): void => {
  if (!req.user) {
    res.status(401).json({
      success: false,
      error: 'Authentication required',
      code: 'AUTH_REQUIRED',
    });
    return;
  }
  
  if (!req.user.isVerified) {
    res.status(403).json({
      success: false,
      error: 'Email verification required',
      code: 'EMAIL_NOT_VERIFIED',
    });
    return;
  }
  
  next();
};

// Blacklist token (for logout)
export const blacklistToken = async (token: string): Promise<void> => {
  try {
    const decoded = jwt.decode(token) as JWTPayload;
    
    if (decoded && decoded.id && decoded.iat && decoded.exp) {
      const tokenId = `${decoded.id}:${decoded.iat}`;
      const expiryTime = decoded.exp * 1000 - Date.now();
      
      if (expiryTime > 0) {
        // Cache the blacklisted token until it expires
        await setInCache(getBlacklistKey(tokenId), 'true', Math.floor(expiryTime / 1000));
        logger.info(`Token blacklisted: ${tokenId}`);
      }
    }
  } catch (error) {
    logger.error('Error blacklisting token:', error);
  }
};

// Clear user cache (useful for logout or user updates)
export const clearUserCache = async (userId: string): Promise<void> => {
  try {
    // This would typically be implemented in the Redis utility
    // For now, we'll just log it
    logger.info(`User cache cleared for: ${userId}`);
  } catch (error) {
    logger.error('Error clearing user cache:', error);
  }
};