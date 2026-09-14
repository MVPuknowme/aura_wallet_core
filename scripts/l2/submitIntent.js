async function submitIntent({ signedIntent, provider }) {
  if (!signedIntent || !signedIntent.signature) {
    throw new Error('A signed intent package is required before submission.');
  }

  if (!provider || typeof provider.sendTransaction !== 'function') {
    throw new Error('An explicit Web3 provider with sendTransaction(transaction) is required.');
  }

  const transaction = signedIntent.transaction || signedIntent.intent;
  const response = await provider.sendTransaction(transaction);

  return Object.freeze({
    transactionHash: response.hash || response.transactionHash,
    submittedAt: new Date().toISOString(),
    network: signedIntent.intent && signedIntent.intent.network,
  });
}

module.exports = { submitIntent };
