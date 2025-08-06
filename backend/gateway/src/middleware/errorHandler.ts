import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

// Error interface
interface APIError extends Error {
  statusCode?: number;
  code?: string;
  details?: any;
}

// Not found handler
export const notFoundHandler = (req: Request, res: Response): void => {
  const message = `Route ${req.originalUrl} not found`;
  
  logger.warn(message, {
    method: req.method,
    url: req.originalUrl,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
  });
  
  res.status(404).json({
    success: false,
    error: message,
    code: 'NOT_FOUND',
  });
};

// Global error handler
export const errorHandler = (
  error: APIError, 
  req: Request, 
  res: Response, 
  next: NextFunction
): void => {
  let statusCode = error.statusCode || 500;
  let message = error.message || 'Internal Server Error';
  let code = error.code || 'INTERNAL_ERROR';
  
  // Log error with context
  logger.error('Error in request', {
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
    },
    request: {
      method: req.method,
      url: req.originalUrl,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      userId: req.user?.id,
    },
    statusCode,
    code,
  });
  
  // Handle specific error types
  if (error.name === 'ValidationError') {
    statusCode = 400;
    code = 'VALIDATION_ERROR';
    message = 'Validation failed';
  } else if (error.name === 'CastError') {
    statusCode = 400;
    code = 'INVALID_FORMAT';
    message = 'Invalid data format';
  } else if (error.name === 'UnauthorizedError') {
    statusCode = 401;
    code = 'UNAUTHORIZED';
    message = 'Unauthorized access';
  } else if (error.name === 'ForbiddenError') {
    statusCode = 403;
    code = 'FORBIDDEN';
    message = 'Access forbidden';
  }
  
  // Don't leak error details in production
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  const errorResponse: any = {
    success: false,
    error: message,
    code,
  };
  
  // Include error details only in development
  if (isDevelopment) {
    errorResponse.details = {
      stack: error.stack,
      ...error.details,
    };
  }
  
  res.status(statusCode).json(errorResponse);
};

// Async error wrapper
export const asyncHandler = (
  fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};