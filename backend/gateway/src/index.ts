import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { config } from './config';
import { setupProxyRoutes } from './routes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/logger';
import { healthCheck } from './middleware/healthCheck';
import { setupRedisClient } from './utils/redis';
import { logger } from './utils/logger';

const app = express();
const PORT = config.port || 3000;

// Trust proxy headers (for rate limiting, etc.)
app.set('trust proxy', 1);

// Basic middleware setup
app.use(helmet());
app.use(cors({
  origin: config.cors.origins,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
}));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
app.use(morgan('combined'));
app.use(requestLogger);

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // Limit each IP to 1000 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.',
    retryAfter: 900, // 15 minutes in seconds
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Health check endpoint
app.get('/health', healthCheck);
app.get('/api/health', healthCheck);

// Setup proxy routes to microservices
setupProxyRoutes(app);

// Fallback for undefined routes
app.use('*', notFoundHandler);

// Error handling middleware
app.use(errorHandler);

// Initialize Redis connection
setupRedisClient()
  .then(() => {
    logger.info('Redis connection established');
    
    // Start server
    app.listen(PORT, () => {
      logger.info(`🚀 API Gateway running on port ${PORT}`);
      logger.info(`📍 Environment: ${config.nodeEnv}`);
      logger.info(`🔗 Health check: http://localhost:${PORT}/health`);
      
      // Log configured services
      logger.info('🔧 Configured microservices:');
      Object.entries(config.services).forEach(([name, serviceConfig]) => {
        logger.info(`   - ${name}: ${serviceConfig.url}`);
      });
    });
  })
  .catch((error) => {
    logger.error('Failed to connect to Redis:', error);
    process.exit(1);
  });

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  process.exit(0);
});

export default app;