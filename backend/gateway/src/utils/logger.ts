import winston from 'winston';
import { config } from '../config';

// Define log levels
const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

// Define colors for each level
const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'white',
};

winston.addColors(colors);

// Determine log level based on environment
const level = () => {
  const env = config.nodeEnv || 'development';
  const isDevelopment = env === 'development';
  return isDevelopment ? 'debug' : 'warn';
};

// Define format for logs
const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: true }),
  winston.format.printf(
    (info) => `${info.timestamp} ${info.level}: ${info.message}`,
  ),
);

// Define format for production logs (JSON)
const productionFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json(),
);

// Define transports
const transports = [
  // Console transport
  new winston.transports.Console({
    format: config.nodeEnv === 'production' ? productionFormat : format,
  }),
  
  // File transport for errors
  new winston.transports.File({
    filename: 'logs/error.log',
    level: 'error',
    format: productionFormat,
    maxsize: 5242880, // 5MB
    maxFiles: 5,
  }),
  
  // File transport for all logs
  new winston.transports.File({
    filename: 'logs/combined.log',
    format: productionFormat,
    maxsize: 5242880, // 5MB
    maxFiles: 5,
  }),
];

// Create logger instance
export const logger = winston.createLogger({
  level: level(),
  levels,
  format: productionFormat,
  transports,
  exitOnError: false,
});

// Create a stream object for Morgan (HTTP request logging)
export const httpLoggerStream = {
  write: (message: string) => {
    logger.http(message.substring(0, message.lastIndexOf('\n')));
  },
};

// Helper functions for structured logging
export const logRequest = (req: any, res: any, responseTime?: number) => {
  const logData = {
    method: req.method,
    url: req.url,
    statusCode: res.statusCode,
    userAgent: req.get('User-Agent'),
    ip: req.ip,
    userId: req.user?.id,
    responseTime: responseTime ? `${responseTime}ms` : undefined,
  };
  
  logger.http('HTTP Request', logData);
};

export const logError = (error: Error, context?: Record<string, any>) => {
  logger.error('Error occurred', {
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
    },
    context,
  });
};

export const logServiceCall = (
  serviceName: string, 
  method: string, 
  url: string, 
  statusCode?: number, 
  responseTime?: number
) => {
  logger.info('Service call', {
    service: serviceName,
    method,
    url,
    statusCode,
    responseTime: responseTime ? `${responseTime}ms` : undefined,
  });
};

export const logUserAction = (
  userId: string, 
  action: string, 
  details?: Record<string, any>
) => {
  logger.info('User action', {
    userId,
    action,
    details,
    timestamp: new Date().toISOString(),
  });
};

export const logSecurityEvent = (
  event: string, 
  severity: 'low' | 'medium' | 'high' | 'critical',
  details?: Record<string, any>
) => {
  const logLevel = severity === 'critical' || severity === 'high' ? 'error' : 'warn';
  
  logger[logLevel]('Security event', {
    event,
    severity,
    details,
    timestamp: new Date().toISOString(),
  });
};

export const logPerformance = (
  operation: string, 
  duration: number, 
  details?: Record<string, any>
) => {
  const level = duration > 5000 ? 'warn' : 'info'; // Warn if operation takes > 5s
  
  logger[level]('Performance metric', {
    operation,
    duration: `${duration}ms`,
    details,
  });
};

// Export default logger
export default logger;