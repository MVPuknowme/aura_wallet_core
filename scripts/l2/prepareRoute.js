#!/usr/bin/env node

function prepareRoute(intent = {}) {
  const route = {
    version: 'skygrid.l2.intent.v1',
    mode: 'review-only',
    network: intent.network || 'base',
    from: intent.from || '<wallet-address-required>',
    to: intent.to || '<destination-required>',
    amount: intent.amount || '0',
    asset: intent.asset || 'AURA',
    memo: intent.memo || 'Aura-Core SkyGrid review package',
    createdAt: intent.createdAt || new Date().toISOString(),
    submitAutomatically: false,
  };

  return Object.freeze(route);
}

if (require.main === module) {
  const route = prepareRoute();
  console.log(JSON.stringify(route, null, 2));
}

module.exports = { prepareRoute };
