import { Application } from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { config } from '../config';
import { authMiddleware, optionalAuth } from '../middleware/auth';
import { logger } from '../utils/logger';

// Proxy options for each service
const createProxyOptions = (serviceUrl: string, timeout: number = 10000) => ({
  target: serviceUrl,
  changeOrigin: true,
  timeout,
  proxyTimeout: timeout,
  onError: (err: Error, req: any, res: any) => {
    logger.error(`Proxy error for ${req.url}:`, err.message);
    res.status(503).json({
      success: false,
      error: 'Service temporarily unavailable',
    });
  },
  onProxyReq: (proxyReq: any, req: any) => {
    // Add request ID for tracing
    proxyReq.setHeader('X-Request-ID', req.id || 'unknown');
    
    // Forward user context if authenticated
    if (req.user) {
      proxyReq.setHeader('X-User-ID', req.user.id);
      proxyReq.setHeader('X-User-Email', req.user.email);
    }
    
    logger.info(`Proxying ${req.method} ${req.url} to ${proxyReq.getHeader('host')}`);
  },
  onProxyRes: (proxyRes: any, req: any) => {
    // Add CORS headers
    proxyRes.headers['Access-Control-Allow-Origin'] = '*';
    proxyRes.headers['Access-Control-Allow-Methods'] = 'GET,PUT,POST,DELETE,OPTIONS';
    proxyRes.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With';
    
    logger.info(`Received response for ${req.method} ${req.url} with status ${proxyRes.statusCode}`);
  },
});

export const setupProxyRoutes = (app: Application) => {
  // Authentication routes (public)
  app.use('/api/auth', createProxyMiddleware({
    ...createProxyOptions(config.services.user.url, config.services.user.timeout),
    pathRewrite: {
      '^/api/auth': '/auth',
    },
  }));

  // User profile routes (authenticated)
  app.use('/api/users', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.user.url, config.services.user.timeout),
    pathRewrite: {
      '^/api/users': '/users',
    },
  }));

  // Catalog/Listing routes (public for viewing, authenticated for CRUD)
  app.use('/api/listings', optionalAuth, createProxyMiddleware({
    ...createProxyOptions(config.services.catalog.url, config.services.catalog.timeout),
    pathRewrite: {
      '^/api/listings': '/listings',
    },
  }));

  // Categories routes (public)
  app.use('/api/categories', createProxyMiddleware({
    ...createProxyOptions(config.services.catalog.url, config.services.catalog.timeout),
    pathRewrite: {
      '^/api/categories': '/categories',
    },
  }));

  // Search routes (public)
  app.use('/api/search', optionalAuth, createProxyMiddleware({
    ...createProxyOptions(config.services.search.url, config.services.search.timeout),
    pathRewrite: {
      '^/api/search': '/search',
    },
  }));

  // Messaging routes (authenticated)
  app.use('/api/messages', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.messaging.url, config.services.messaging.timeout),
    pathRewrite: {
      '^/api/messages': '/messages',
    },
  }));

  // Conversation routes (authenticated)
  app.use('/api/conversations', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.messaging.url, config.services.messaging.timeout),
    pathRewrite: {
      '^/api/conversations': '/conversations',
    },
  }));

  // Offer routes (authenticated)
  app.use('/api/offers', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.messaging.url, config.services.messaging.timeout),
    pathRewrite: {
      '^/api/offers': '/offers',
    },
  }));

  // Payment routes (authenticated)
  app.use('/api/payments', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.payment.url, config.services.payment.timeout),
    pathRewrite: {
      '^/api/payments': '/payments',
    },
  }));

  // Order routes (authenticated)
  app.use('/api/orders', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.payment.url, config.services.payment.timeout),
    pathRewrite: {
      '^/api/orders': '/orders',
    },
  }));

  // Shipping routes (authenticated)
  app.use('/api/shipping', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.shipping.url, config.services.shipping.timeout),
    pathRewrite: {
      '^/api/shipping': '/shipping',
    },
  }));

  // Notification routes (authenticated)
  app.use('/api/notifications', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.notification.url, config.services.notification.timeout),
    pathRewrite: {
      '^/api/notifications': '/notifications',
    },
  }));

  // File upload routes (authenticated)
  app.use('/api/upload', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.catalog.url, config.services.catalog.timeout),
    pathRewrite: {
      '^/api/upload': '/upload',
    },
  }));

  // WebSocket proxy for real-time features (messaging)
  app.use('/api/ws', authMiddleware, createProxyMiddleware({
    ...createProxyOptions(config.services.messaging.url, config.services.messaging.timeout),
    ws: true, // Enable WebSocket proxying
    pathRewrite: {
      '^/api/ws': '/ws',
    },
  }));

  logger.info('Proxy routes configured successfully');
};