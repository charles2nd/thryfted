import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { logger, logRequest } from '../utils/logger';

// Extend Request interface to include request ID
declare global {
  namespace Express {
    interface Request {
      id?: string;
      startTime?: number;
    }
  }
}

// Request logger middleware
export const requestLogger = (req: Request, res: Response, next: NextFunction): void => {
  // Generate unique request ID
  req.id = uuidv4();
  req.startTime = Date.now();
  
  // Add request ID to response headers
  res.setHeader('X-Request-ID', req.id);
  
  // Log request start
  logger.info('Request started', {
    requestId: req.id,
    method: req.method,
    url: req.url,
    userAgent: req.get('User-Agent'),
    ip: req.ip,
    userId: req.user?.id,
  });
  
  // Override res.end to log response
  const originalEnd = res.end;
  
  res.end = function(chunk: any, encoding?: any) {
    res.end = originalEnd;
    
    if (req.startTime) {
      const responseTime = Date.now() - req.startTime;
      
      logRequest(req, res, responseTime);
      
      logger.info('Request completed', {
        requestId: req.id,
        statusCode: res.statusCode,
        responseTime: `${responseTime}ms`,
      });
    }
    
    return originalEnd.call(this, chunk, encoding);
  };
  
  next();
};