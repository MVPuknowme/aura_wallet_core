import { readFileSync } from 'node:fs';

const packageJson = readFileSync('package.json', 'utf8');
const readme = readFileSync('README.md', 'utf8');
const lockfile = readFileSync('pnpm-lock.yaml', 'utf8');

if (!packageJson.includes('pnpm@10.28.1')) {
  throw new Error('package.json is not pinned to pnpm@10.28.1');
}

if (!lockfile.includes("lockfileVersion: '9.0'")) {
  throw new Error('pnpm-lock.yaml is not a pnpm v9 lockfile');
}

if (!readme.includes('SKYGRID Emergency Data On-Ramp')) {
  throw new Error('README.md must preserve SKYGRID Emergency Data On-Ramp product naming');
}

console.log('Manifest sync validation passed.');
