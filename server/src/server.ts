import { buildApp } from './app.js';
import { loadConfig } from './lib/config.js';
import { prisma } from './lib/prisma.js';

const config = loadConfig();
const app = await buildApp();

for (const signal of ['SIGINT', 'SIGTERM'] as const) {
  process.on(signal, async () => {
    await app.close();
    await prisma.$disconnect();
    process.exit(0);
  });
}

try {
  await app.listen({ host: config.HOST, port: config.PORT });
} catch (error) {
  app.log.error(error);
  await prisma.$disconnect();
  process.exit(1);
}
