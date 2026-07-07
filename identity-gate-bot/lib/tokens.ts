import { createHash, randomBytes } from 'crypto';

export function hashSecret(value: string): string {
  return createHash('sha256').update(value).digest('hex');
}

export function createOneTimeToken() {
  const token = randomBytes(24).toString('base64url');
  return { token, tokenHash: hashSecret(token) };
}
