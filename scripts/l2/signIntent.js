async function signIntent({ intent, wallet }) {
  if (!intent) {
    throw new Error('A reviewed intent is required before signing.');
  }

  if (!wallet || typeof wallet.signMessage !== 'function') {
    throw new Error('An explicit wallet signer with signMessage(message) is required.');
  }

  const message = JSON.stringify({ ...intent, operatorApproved: true });
  const signature = await wallet.signMessage(message);

  return Object.freeze({
    intent,
    signature,
    signedAt: new Date().toISOString(),
    autoSubmitted: false,
  });
}

module.exports = { signIntent };
