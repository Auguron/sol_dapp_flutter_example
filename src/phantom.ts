const solanaWeb3 = require('@solana/web3.js');

export async function connect(): solanaWeb3.PublicKey {
  const resp = await window.solana.connect();
  return new solanaWeb3.PublicKey(resp.publicKey.toString());
}

export function disconnect() {
  window.solana.disconnect();
}

export function isPhantomInstalled(): bool {
  return window.solana && window.solana.isPhantom;
}

export async function signTransaction(tx: solanaWeb3.Transaction): solanaWeb3.Transaction {
  return await window.solana.signTransaction(tx);
}
