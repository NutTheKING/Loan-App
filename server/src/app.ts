import { mkdir } from 'node:fs/promises';

import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import jwt from '@fastify/jwt';
import multipart from '@fastify/multipart';
import rateLimit from '@fastify/rate-limit';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';
import Fastify, { type FastifyInstance } from 'fastify';

import { loadConfig } from './lib/config.js';
import { registerErrorHandler } from './lib/errors.js';
import { registerAccountRoutes } from './routes/account.js';
import { registerAdminRoutes } from './routes/admin.js';
import { registerAuthRoutes } from './routes/auth.js';
import { registerLoanRoutes } from './routes/loans.js';

export async function buildApp(): Promise<FastifyInstance> {
  const config = loadConfig();
  const app = Fastify({ logger: true, bodyLimit: config.MAX_UPLOAD_BYTES });

  await mkdir(config.uploadDirectory, { recursive: true });
  await app.register(helmet, { contentSecurityPolicy: false });
  await app.register(cors, {
    origin: (origin, callback) => {
      const isLocalDevelopmentOrigin =
          process.env.NODE_ENV !== 'production' && /^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(origin ?? '');
      if (!origin || config.corsOrigins.includes(origin) || isLocalDevelopmentOrigin) {
        callback(null, true);
        return;
      }
      callback(null, false);
    },
    methods: ['GET', 'POST', 'PATCH', 'DELETE'],
  });
  await app.register(rateLimit, { max: 100, timeWindow: '1 minute' });
  await app.register(jwt, { secret: config.JWT_ACCESS_SECRET });
  await app.register(multipart, { limits: { fileSize: config.MAX_UPLOAD_BYTES, files: 1 } });
  await app.register(swagger, {
    openapi: {
      info: { title: 'Loan App API', version: '1.0.0', description: 'Customer and staff API for the loan application.' },
      components: { securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' } } },
    },
  });
  await app.register(swaggerUi, { routePrefix: '/docs' });

  registerErrorHandler(app);
  app.get('/', { schema: { hide: true } }, async () => ({
    name: 'Loan App API',
    status: 'online',
    website: 'http://127.0.0.1:8080/#/login',
    admin: 'http://127.0.0.1:8080/#/admin',
    documentation: 'http://127.0.0.1:4000/docs',
    health: 'http://127.0.0.1:4000/health',
    apiBaseUrl: 'http://127.0.0.1:4000/api/v1',
  }));
  app.get('/health', { schema: { tags: ['System'], summary: 'Check API health' } }, async () => ({ status: 'ok' }));
  await app.register(registerAuthRoutes, { prefix: '/api/v1' });
  await app.register((instance) => registerLoanRoutes(instance, config), { prefix: '/api/v1' });
  await app.register(registerAccountRoutes, { prefix: '/api/v1' });
  await app.register(registerAdminRoutes, { prefix: '/api/v1' });

  return app;
}
