import { createHmac, randomBytes } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import type { User, UserRole } from '@prisma/client';

import { prisma } from './prisma.js';

const refreshTokenLifetimeDays = 30;

export type PublicUser = Pick<User, 'id' | 'email' | 'fullName' | 'idNumber' | 'role' | 'createdAt'>;

export function publicUser(user: User): PublicUser {
  return {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    idNumber: user.idNumber,
    role: user.role,
    createdAt: user.createdAt,
  };
}

export function hashRefreshToken(token: string): string {
  const refreshTokenSecret = process.env.JWT_REFRESH_SECRET;
  if (!refreshTokenSecret) {
    throw new Error('JWT_REFRESH_SECRET is required.');
  }
  return createHmac('sha256', refreshTokenSecret).update(token).digest('base64url');
}

export async function createSession(app: FastifyInstance, user: User): Promise<{ accessToken: string; refreshToken: string }> {
  const payload = { sub: user.id, email: user.email, role: user.role as UserRole };
  const accessToken = await app.jwt.sign(payload, { expiresIn: '15m' });
  const refreshToken = randomBytes(48).toString('base64url');
  const expiresAt = new Date(Date.now() + refreshTokenLifetimeDays * 24 * 60 * 60 * 1000);

  await prisma.refreshToken.create({
    data: { userId: user.id, tokenHash: hashRefreshToken(refreshToken), expiresAt },
  });

  return { accessToken, refreshToken };
}

export async function rotateSession(app: FastifyInstance, refreshToken: string): Promise<{ accessToken: string; refreshToken: string; user: User } | null> {
  const tokenHash = hashRefreshToken(refreshToken);
  const storedToken = await prisma.refreshToken.findUnique({
    where: { tokenHash },
    include: { user: true },
  });

  if (!storedToken || storedToken.revokedAt || storedToken.expiresAt <= new Date() || !storedToken.user.isActive) {
    return null;
  }

  await prisma.refreshToken.update({ where: { id: storedToken.id }, data: { revokedAt: new Date() } });
  const nextSession = await createSession(app, storedToken.user);
  return { ...nextSession, user: storedToken.user };
}
