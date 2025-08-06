import { Request, Response } from 'express';
import { config } from '../config';
import { getRedisClient } from '../utils/redis';
import { logger } from '../utils/logger';

interface HealthStatus {
  status: 'healthy' | 'unhealthy' | 'degraded';
  timestamp: string;
  uptime: number;
  version: string;
  environment: string;
  services: {
    redis: 'healthy' | 'unhealthy';
    [key: string]: 'healthy' | 'unhealthy';
  };
  memory: {
    used: number;
    total: number;
    percentage: number;
  };
}

// Check Redis health
const checkRedisHealth = async (): Promise<'healthy' | 'unhealthy'> => {
  try {
    const client = getRedisClient();
    await client.ping();
    return 'healthy';
  } catch (error) {
    logger.error('Redis health check failed:', error);
    return 'unhealthy';
  }
};

// Check microservice health
const checkServiceHealth = async (serviceName: string, url: string): Promise<'healthy' | 'unhealthy'> => {
  try {
    const fetch = (await import('node-fetch')).default;
    const response = await fetch(`${url}/health`, {
      method: 'GET',
      timeout: 5000,
    });
    
    return response.ok ? 'healthy' : 'unhealthy';
  } catch (error) {
    logger.debug(`Service ${serviceName} health check failed:`, error);
    return 'unhealthy';
  }
};

// Get memory usage
const getMemoryUsage = () => {
  const memUsage = process.memoryUsage();
  const totalMemory = memUsage.heapTotal;
  const usedMemory = memUsage.heapUsed;
  
  return {
    used: Math.round(usedMemory / 1024 / 1024), // MB
    total: Math.round(totalMemory / 1024 / 1024), // MB
    percentage: Math.round((usedMemory / totalMemory) * 100),
  };
};

// Health check endpoint
export const healthCheck = async (req: Request, res: Response): Promise<void> => {
  const startTime = Date.now();
  
  try {
    // Check Redis
    const redisStatus = await checkRedisHealth();
    
    // Check configured microservices (optional - can be slow)
    const serviceChecks: Record<string, 'healthy' | 'unhealthy'> = {
      redis: redisStatus,
    };
    
    // Only check service health in detailed mode or if specifically requested
    const detailed = req.query.detailed === 'true';
    
    if (detailed) {
      const servicePromises = Object.entries(config.services).map(async ([name, serviceConfig]) => {
        const status = await checkServiceHealth(name, serviceConfig.url);
        return [name, status];
      });
      
      const serviceResults = await Promise.all(servicePromises);
      serviceResults.forEach(([name, status]) => {
        serviceChecks[name] = status as 'healthy' | 'unhealthy';
      });
    }
    
    // Determine overall status
    const unhealthyServices = Object.values(serviceChecks).filter(status => status === 'unhealthy');
    let overallStatus: 'healthy' | 'unhealthy' | 'degraded' = 'healthy';
    
    if (unhealthyServices.length > 0) {
      // If Redis is unhealthy, mark as unhealthy, otherwise degraded
      overallStatus = redisStatus === 'unhealthy' ? 'unhealthy' : 'degraded';
    }
    
    const healthStatus: HealthStatus = {
      status: overallStatus,
      timestamp: new Date().toISOString(),
      uptime: Math.floor(process.uptime()),
      version: '1.0.0', // Could read from package.json
      environment: config.nodeEnv,
      services: serviceChecks,
      memory: getMemoryUsage(),
    };
    
    const responseTime = Date.now() - startTime;
    
    // Log health check (debug level to avoid spam)
    logger.debug('Health check completed', {
      status: overallStatus,
      responseTime: `${responseTime}ms`,
      detailed,
    });
    
    // Set appropriate status code
    const statusCode = overallStatus === 'healthy' ? 200 : overallStatus === 'degraded' ? 207 : 503;
    
    res.status(statusCode).json(healthStatus);
  } catch (error) {
    const responseTime = Date.now() - startTime;
    
    logger.error('Health check error:', {
      error: error instanceof Error ? error.message : 'Unknown error',
      responseTime: `${responseTime}ms`,
    });
    
    res.status(503).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: 'Health check failed',
      uptime: Math.floor(process.uptime()),
      version: '1.0.0',
      environment: config.nodeEnv,
    });
  }
};

// Simple liveness probe (for Kubernetes)
export const livenessProbe = (req: Request, res: Response): void => {
  res.status(200).json({
    status: 'alive',
    timestamp: new Date().toISOString(),
  });
};

// Simple readiness probe (for Kubernetes)
export const readinessProbe = async (req: Request, res: Response): Promise<void> => {
  try {
    // Check if essential services are available
    const redisStatus = await checkRedisHealth();
    
    if (redisStatus === 'healthy') {
      res.status(200).json({
        status: 'ready',
        timestamp: new Date().toISOString(),
      });
    } else {
      res.status(503).json({
        status: 'not_ready',
        timestamp: new Date().toISOString(),
        reason: 'Redis unavailable',
      });
    }
  } catch (error) {
    res.status(503).json({
      status: 'not_ready',
      timestamp: new Date().toISOString(),
      reason: 'Health check failed',
    });
  }
};