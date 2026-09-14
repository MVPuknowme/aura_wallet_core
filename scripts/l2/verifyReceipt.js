async function verifyReceipt({ transactionHash, provider }) {
  if (!transactionHash) {
    throw new Error('transactionHash is required for receipt verification.');
  }

  if (!provider || typeof provider.getTransactionReceipt !== 'function') {
    throw new Error('A provider with getTransactionReceipt(hash) is required.');
  }

  const receipt = await provider.getTransactionReceipt(transactionHash);

  return Object.freeze({
    transactionHash,
    status: receipt && receipt.status ? 'confirmed' : 'pending-or-failed',
    blockNumber: receipt && receipt.blockNumber,
    verifiedAt: new Date().toISOString(),
    rawReceipt: receipt,
  });
}

module.exports = { verifyReceipt };
