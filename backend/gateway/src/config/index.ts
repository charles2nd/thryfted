import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

interface ServiceConfig {
  url: string;
  timeout: number;
  retries: number;
}

interface Config {
  nodeEnv: string;
  port: number;
  jwtSecret: string;
  jwtExpiry: string;
  redis: {
    host: string;
    port: number;
    password?: string;
    db: number;
  };
  cors: {
    origins: string[];
  };
  services: {
    [key: string]: ServiceConfig;
  };
  rateLimit: {
    windowMs: number;
    max: number;
  };
  upload: {
    maxFileSize: number;
    allowedMimeTypes: string[];
  };
}

export const config: Config = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  jwtSecret: process.env.JWT_SECRET || 'thryfted-super-secret-key-change-in-production',
  jwtExpiry: process.env.JWT_EXPIRY || '7d',
  
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379', 10),
    password: process.env.REDIS_PASSWORD,
    db: parseInt(process.env.REDIS_DB || '0', 10),
  },
  
  cors: {
    origins: process.env.CORS_ORIGINS 
      ? process.env.CORS_ORIGINS.split(',') 
      : ['http://localhost:3000', 'http://localhost:8081'],
  },
  
  services: {
    user: {
      url: process.env.USER_SERVICE_URL || 'http://localhost:3001',
      timeout: 10000,
      retries: 3,
    },
    catalog: {
      url: process.env.CATALOG_SERVICE_URL || 'http://localhost:3002',
      timeout: 10000,
      retries: 3,
    },
    search: {
      url: process.env.SEARCH_SERVICE_URL || 'http://localhost:3003',
      timeout: 15000,
      retries: 2,
    },
    messaging: {
      url: process.env.MESSAGING_SERVICE_URL || 'http://localhost:3004',
      timeout: 10000,
      retries: 3,
    },
    payment: {
      url: process.env.PAYMENT_SERVICE_URL || 'http://localhost:3005',
      timeout: 30000, // Payment operations need more time
      retries: 2,
    },
    shipping: {
      url: process.env.SHIPPING_SERVICE_URL || 'http://localhost:3006',
      timeout: 15000,
      retries: 3,
    },
    notification: {
      url: process.env.NOTIFICATION_SERVICE_URL || 'http://localhost:3007',
      timeout: 10000,
      retries: 3,
    },
  },
  
  rateLimit: {
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX || '1000', 10),
  },
  
  upload: {
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE || '10485760', 10), // 10MB
    allowedMimeTypes: [
      'image/jpeg',
      'image/png', 
      'image/webp',
      'image/gif',
    ],
  },
};

// Validate required environment variables in production
if (config.nodeEnv === 'production') {
  const requiredEnvVars = [
    'JWT_SECRET',
    'REDIS_HOST',
    'USER_SERVICE_URL',
    'CATALOG_SERVICE_URL',
    'SEARCH_SERVICE_URL',
    'MESSAGING_SERVICE_URL',
    'PAYMENT_SERVICE_URL',
    'SHIPPING_SERVICE_URL',
    'NOTIFICATION_SERVICE_URL',
  ];
  
  const missing = requiredEnvVars.filter(envVar => !process.env[envVar]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }
}

export default config;