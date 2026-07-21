import { randomBytes, scrypt as scryptCallback, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';

const scrypt = promisify(scryptCallback);
const keyLength = 64;

export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16);
  const derivedKey = (await scrypt(password, salt, keyLength)) as Buffer;
  return `scrypt$${salt.toString('base64url')}$${derivedKey.toString('base64url')}`;
}

export async function verifyPassword(password: string, encodedHash: string): Promise<boolean> {
  const [algorithm, encodedSalt, encodedKey] = encodedHash.split('$');
  if (algorithm !== 'scrypt' || !encodedSalt || !encodedKey) {
    return false;
  }

  const expectedKey = Buffer.from(encodedKey, 'base64url');
  const derivedKey = (await scrypt(password, Buffer.from(encodedSalt, 'base64url'), keyLength)) as Buffer;
  return expectedKey.length === derivedKey.length && timingSafeEqual(expectedKey, derivedKey);
}
