import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { PrismaClient } from '@prisma/client';
import { parse } from 'dotenv';

const sourceEnvironment = parse(readFileSync(resolve('.env')));
const targetEnvironment = parse(readFileSync(resolve('.env.render')));
const sourceUrl = sourceEnvironment.DATABASE_URL;
const targetUrl = targetEnvironment.RENDER_DATABASE_URL;

if (!sourceUrl || !targetUrl) {
  throw new Error('DATABASE_URL and RENDER_DATABASE_URL must both be configured.');
}

const source = new PrismaClient({ datasources: { db: { url: sourceUrl } } });
const target = new PrismaClient({ datasources: { db: { url: targetUrl } } });

const models = [
  'permission',
  'user',
  'loanProduct',
  'branch',
  'rolePermission',
  'userPermission',
  'loan',
  'loanDocument',
  'repayment',
  'transaction',
  'notification',
  'auditLog',
  'refreshToken',
  'deviceToken',
] as const;

try {
  const sourceData = new Map<string, unknown[]>();
  const sourceCounts: Record<string, number> = {};
  const targetCounts: Record<string, number> = {};

  for (const modelName of models) {
    const sourceModel = source[modelName] as unknown as {
      findMany(): Promise<unknown[]>;
    };
    const targetModel = target[modelName] as unknown as {
      count(): Promise<number>;
    };
    const rows = await sourceModel.findMany();
    sourceData.set(modelName, rows);
    sourceCounts[modelName] = rows.length;
    targetCounts[modelName] = await targetModel.count();
  }

  const seededModels = new Set(['permission', 'loanProduct', 'branch', 'rolePermission']);
  const unexpectedTargets = Object.entries(targetCounts).filter(
    ([name, count]) => count > 0 && !seededModels.has(name),
  );
  if (unexpectedTargets.length > 0) {
    throw new Error(
      `Render database contains non-seed data: ${unexpectedTargets
        .map(([name, count]) => `${name}=${count}`)
        .join(', ')}`,
    );
  }

  const deleteOperations = [...models].reverse().map((modelName) => {
    const targetModel = target[modelName] as unknown as {
      deleteMany(): unknown;
    };
    return targetModel.deleteMany();
  });
  const createOperations = models.flatMap((modelName) => {
    const rows = sourceData.get(modelName) ?? [];
    if (rows.length === 0) return [];
    const targetModel = target[modelName] as unknown as {
      createMany(input: { data: unknown[] }): unknown;
    };
    return [targetModel.createMany({ data: rows })];
  });

  await target.$transaction(
    [...deleteOperations, ...createOperations] as never[],
    { timeout: 120_000 },
  );

  const verifiedCounts: Record<string, number> = {};
  for (const modelName of models) {
    const targetModel = target[modelName] as unknown as {
      count(): Promise<number>;
    };
    verifiedCounts[modelName] = await targetModel.count();
  }

  const mismatches = models.filter(
    (modelName) => sourceCounts[modelName] !== verifiedCounts[modelName],
  );
  if (mismatches.length > 0) {
    throw new Error(`Count verification failed for: ${mismatches.join(', ')}`);
  }

  console.log(JSON.stringify({ sourceCounts, renderCounts: verifiedCounts }, null, 2));
} finally {
  await Promise.all([source.$disconnect(), target.$disconnect()]);
}
