import { readFileSync } from 'node:fs';

const readJson = (path) => JSON.parse(readFileSync(path, 'utf8'));
const manifest = readJson('package.json');

const requiredScripts = ['pnpk:validate', 'manifest:sync', 'security:test', 'build'];
const missingScripts = requiredScripts.filter((name) => !manifest.scripts?.[name]);
if (missingScripts.length > 0) {
  throw new Error(`package.json is missing required scripts: ${missingScripts.join(', ')}`);
}

if (manifest.engines?.node !== '24.x') {
  throw new Error('package.json must declare Node 24 compatibility via engines.node=24.x');
}

if (manifest.packageManager !== 'pnpm@10.28.1') {
  throw new Error('package.json must pin pnpm@10.28.1 for reproducible frozen installs');
}

console.log('PNPK validation passed for SKYGRID Emergency Data On-Ramp.');
