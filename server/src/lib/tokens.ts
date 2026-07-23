import { createHmac, randomBytes } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import type { User, UserRole } from '@prisma/client';

import { prisma } from './prisma.js';
import { getEffectivePermissions } from './permissions.js';

const refreshTokenLifetimeDays = 30;

export type PublicUser = Pick<User, 'id' | 'email' | 'fullName' | 'idNumber' | 'role' | 'createdAt'> & {
  permissions: string[];
};

export async function publicUser(user: User): Promise<PublicUser> {
  return {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    idNumber: user.idNumber,
    role: user.role,
    createdAt: user.createdAt,
    permissions: await getEffectivePermissions(user.id, user.role),
  };
}

export function hashRefreshToken(token: string): string {
  const refreshTokenSecret = process.env.JWT_REFRESH_SECRET;
  if (!refreshTokenSecret) {
    throw new Error('JWT_REFRESH_SECRET is required.');
  }
  return createHmac('sha256', refreshTokenSecret).update(token).digest('base64url');
}

function refreshTokenExpiry(): Date {
  return new Date(Date.now() + refreshTokenLifetimeDays * 24 * 60 * 60 * 1000);
}

async function signAccessToken(app: FastifyInstance, user: User, sessionId: string): Promise<string> {
  const payload = { sub: user.id, sid: sessionId, email: user.email, role: user.role as UserRole };
  return app.jwt.sign(payload, { expiresIn: '15m' });
}

export async function createSession(app: FastifyInstance, user: User): Promise<{ accessToken: string; refreshToken: string }> {
  const refreshToken = randomBytes(48).toString('base64url');
  const now = new Date();
  const storedSession = await prisma.$transaction(async (transaction) => {
    await transaction.$queryRaw`SELECT "id" FROM "User" WHERE "id" = ${user.id}::uuid FOR UPDATE`;
    await transaction.refreshToken.deleteMany({ where: { userId: user.id } });
    await transaction.deviceToken.deleteMany({ where: { userId: user.id } });
    await transaction.user.update({
      where: { id: user.id },
      data: { lastLoginAt: now, lastSeenAt: now, lastLogoutAt: null },
    });
    return transaction.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: hashRefreshToken(refreshToken),
        expiresAt: refreshTokenExpiry(),
      },
    });
  });

  const accessToken = await signAccessToken(app, user, storedSession.id);
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

  const nextRefreshToken = randomBytes(48).toString('base64url');
  const rotated = await prisma.refreshToken.updateMany({
    where: { id: storedToken.id, tokenHash, revokedAt: null },
    data: {
      tokenHash: hashRefreshToken(nextRefreshToken),
      expiresAt: refreshTokenExpiry(),
    },
  });
  if (rotated.count !== 1) {
    return null;
  }

  await prisma.user.update({
    where: { id: storedToken.userId },
    data: { lastSeenAt: new Date() },
  });
  const accessToken = await signAccessToken(app, storedToken.user, storedToken.id);
  return { accessToken, refreshToken: nextRefreshToken, user: storedToken.user };
}
