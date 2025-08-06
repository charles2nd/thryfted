import Redis from 'ioredis';
import { config } from '../config';
import { logger } from './logger';

let redisClient: Redis | null = null;

// Redis connection configuration
const redisConfig = {
  host: config.redis.host,
  port: config.redis.port,
  password: config.redis.password,
  db: config.redis.db,
  retryDelayOnFailover: 100,
  maxRetriesPerRequest: 3,
  lazyConnect: true,
  keepAlive: 30000,
};

// Setup Redis client
export const setupRedisClient = async (): Promise<Redis> => {
  if (redisClient) {
    return redisClient;
  }

  try {
    redisClient = new Redis(redisConfig);

    // Event listeners
    redisClient.on('connect', () => {
      logger.info('Redis connected');
    });

    redisClient.on('ready', () => {
      logger.info('Redis ready');
    });

    redisClient.on('error', (error) => {
      logger.error('Redis error:', error);
    });

    redisClient.on('close', () => {
      logger.warn('Redis connection closed');
    });

    redisClient.on('reconnecting', () => {
      logger.info('Redis reconnecting...');
    });

    // Test connection
    await redisClient.connect();
    await redisClient.ping();

    logger.info('Redis client setup complete');
    return redisClient;
  } catch (error) {
    logger.error('Failed to setup Redis client:', error);
    throw error;
  }
};

// Get Redis client instance
export const getRedisClient = (): Redis => {
  if (!redisClient) {
    throw new Error('Redis client not initialized. Call setupRedisClient() first.');
  }
  return redisClient;
};

// Cache operations
export const setInCache = async (
  key: string, 
  value: string, 
  expireInSeconds?: number
): Promise<void> => {
  try {
    const client = getRedisClient();
    
    if (expireInSeconds) {
      await client.setex(key, expireInSeconds, value);
    } else {
      await client.set(key, value);
    }
    
    logger.debug(`Cache set: ${key}`);
  } catch (error) {
    logger.error(`Error setting cache key ${key}:`, error);
    throw error;
  }
};

export const getFromCache = async (key: string): Promise<string | null> => {
  try {
    const client = getRedisClient();
    const value = await client.get(key);
    
    logger.debug(`Cache get: ${key} - ${value ? 'hit' : 'miss'}`);
    return value;
  } catch (error) {
    logger.error(`Error getting cache key ${key}:`, error);
    return null;
  }
};

export const deleteFromCache = async (key: string): Promise<void> => {
  try {
    const client = getRedisClient();
    await client.del(key);
    
    logger.debug(`Cache delete: ${key}`);
  } catch (error) {
    logger.error(`Error deleting cache key ${key}:`, error);
    throw error;
  }
};

export const existsInCache = async (key: string): Promise<boolean> => {
  try {
    const client = getRedisClient();
    const exists = await client.exists(key);
    
    return exists === 1;
  } catch (error) {
    logger.error(`Error checking cache key ${key}:`, error);
    return false;
  }
};

export const incrementInCache = async (key: string, expireInSeconds?: number): Promise<number> => {
  try {
    const client = getRedisClient();
    const value = await client.incr(key);
    
    if (expireInSeconds && value === 1) {
      // Set expiry only on first increment
      await client.expire(key, expireInSeconds);
    }
    
    return value;
  } catch (error) {
    logger.error(`Error incrementing cache key ${key}:`, error);
    throw error;
  }
};

export const setHashInCache = async (
  key: string, 
  hash: Record<string, string>, 
  expireInSeconds?: number
): Promise<void> => {
  try {
    const client = getRedisClient();
    await client.hmset(key, hash);
    
    if (expireInSeconds) {
      await client.expire(key, expireInSeconds);
    }
    
    logger.debug(`Hash cache set: ${key}`);
  } catch (error) {
    logger.error(`Error setting hash cache key ${key}:`, error);
    throw error;
  }
};

export const getHashFromCache = async (key: string): Promise<Record<string, string> | null> => {
  try {
    const client = getRedisClient();
    const hash = await client.hgetall(key);
    
    logger.debug(`Hash cache get: ${key} - ${Object.keys(hash).length > 0 ? 'hit' : 'miss'}`);
    return Object.keys(hash).length > 0 ? hash : null;
  } catch (error) {
    logger.error(`Error getting hash cache key ${key}:`, error);
    return null;
  }
};

// Pattern-based operations
export const deleteByPattern = async (pattern: string): Promise<number> => {
  try {
    const client = getRedisClient();
    const keys = await client.keys(pattern);
    
    if (keys.length === 0) {
      return 0;
    }
    
    const deletedCount = await client.del(...keys);
    logger.debug(`Cache pattern delete: ${pattern} - ${deletedCount} keys deleted`);
    
    return deletedCount;
  } catch (error) {
    logger.error(`Error deleting cache pattern ${pattern}:`, error);
    throw error;
  }
};

// Session/rate limiting helpers
export const getRateLimitInfo = async (
  identifier: string, 
  windowMs: number, 
  maxRequests: number
): Promise<{count: number; resetTime: Date; remaining: number}> => {
  try {
    const client = getRedisClient();
    const key = `rate_limit:${identifier}`;
    const windowSeconds = Math.floor(windowMs / 1000);
    
    const count = await incrementInCache(key, windowSeconds);
    const ttl = await client.ttl(key);
    
    const resetTime = new Date(Date.now() + (ttl * 1000));
    const remaining = Math.max(0, maxRequests - count);
    
    return {
      count,
      resetTime,
      remaining,
    };
  } catch (error) {
    logger.error(`Error getting rate limit info for ${identifier}:`, error);
    // Return safe defaults on error
    return {
      count: 0,
      resetTime: new Date(Date.now() + windowMs),
      remaining: maxRequests,
    };
  }
};

// Graceful shutdown
export const closeRedisConnection = async (): Promise<void> => {
  if (redisClient) {
    try {
      await redisClient.quit();
      logger.info('Redis connection closed gracefully');
    } catch (error) {
      logger.error('Error closing Redis connection:', error);
    }
  }
};