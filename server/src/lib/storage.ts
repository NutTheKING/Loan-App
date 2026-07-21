import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { basename, extname, join } from 'node:path';
import { randomUUID } from 'node:crypto';

import type { AppConfig } from './config.js';

export async function savePrivateDocument(config: AppConfig, input: { loanId: string; filename: string; bytes: Buffer }): Promise<string> {
  const extension = extname(basename(input.filename)).toLowerCase();
  const safeExtension = ['.jpg', '.jpeg', '.png', '.webp'].includes(extension) ? extension : '.bin';
  const directory = join(config.uploadDirectory, input.loanId);
  await mkdir(directory, { recursive: true });
  const storageKey = `${input.loanId}/${randomUUID()}${safeExtension}`;
  await writeFile(join(config.uploadDirectory, storageKey), input.bytes, { flag: 'wx' });
  return storageKey;
}

export function readPrivateDocument(config: AppConfig, storageKey: string): Promise<Buffer> {
  return readFile(join(config.uploadDirectory, storageKey));
}
