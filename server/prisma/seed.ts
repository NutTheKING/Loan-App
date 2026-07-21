import 'dotenv/config';
import { PrismaClient, UserRole } from '@prisma/client';

import { hashPassword } from '../src/lib/password.js';

const email = process.env.ADMIN_EMAIL?.trim().toLowerCase();
const password = process.env.ADMIN_PASSWORD;

if (!email || !password || password.length < 12) {
  throw new Error('Set ADMIN_EMAIL and an ADMIN_PASSWORD of at least 12 characters before seeding.');
}

const prisma = new PrismaClient();

await prisma.user.upsert({
  where: { email },
  create: {
    email,
    fullName: 'Loan administrator',
    passwordHash: await hashPassword(password),
    role: UserRole.ADMIN,
  },
  update: {
    passwordHash: await hashPassword(password),
    role: UserRole.ADMIN,
    isActive: true,
  },
});

await prisma.$disconnect();
