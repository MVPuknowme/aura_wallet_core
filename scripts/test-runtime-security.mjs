import { readFileSync } from 'node:fs';

const readme = readFileSync('README.md', 'utf8');
const providerGateway = readFileSync('identity-gate-bot/lib/provider/gateway.ts', 'utf8');

const requiredReadmePhrases = [
  'fail-closed',
  'SKYGRID Emergency Data On-Ramp',
  'does not add autonomous control',
  'private data movement',
  'custody',
  'signing',
  'broadcasting'
];

for (const phrase of requiredReadmePhrases) {
  if (!readme.includes(phrase)) {
    throw new Error(`Security documentation is missing required phrase: ${phrase}`);
  }
}

if (!providerGateway.includes("'SKYGRID Emergency Data On-Ramp'")) {
  throw new Error('Provider gateway product name changed unexpectedly');
}

console.log('Security regression checks passed.');
