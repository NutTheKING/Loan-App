import 'dotenv/config';

import { resolve } from 'node:path';
import { z } from 'zod';

const environmentSchema = z.object({
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required.'),
  JWT_ACCESS_SECRET: z.string().min(32, 'JWT_ACCESS_SECRET must contain at least 32 characters.'),
  JWT_REFRESH_SECRET: z.string().min(32, 'JWT_REFRESH_SECRET must contain at least 32 characters.'),
  PORT: z.coerce.number().int().min(1).max(65535).default(4000),
  HOST: z.string().default('0.0.0.0'),
  CORS_ORIGIN: z.string().default('http://localhost:5000,http://localhost:3000'),
  UPLOAD_DIRECTORY: z.string().default('./uploads'),
  MAX_UPLOAD_BYTES: z.coerce.number().int().positive().max(20 * 1024 * 1024).default(10 * 1024 * 1024),
});

export type AppConfig = ReturnType<typeof loadConfig>;

export function loadConfig() {
  const parsed = environmentSchema.safeParse(process.env);
  if (!parsed.success) {
    throw new Error(`Invalid server configuration: ${parsed.error.issues.map((issue) => issue.message).join(' ')}`);
  }

  return {
    ...parsed.data,
    corsOrigins: parsed.data.CORS_ORIGIN.split(',').map((origin) => origin.trim()).filter(Boolean),
    uploadDirectory: resolve(parsed.data.UPLOAD_DIRECTORY),
  };
}
