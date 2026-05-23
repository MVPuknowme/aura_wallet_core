# SkyGrid Web3 On-Ramp Postman Examples

## POST /api/web3/onramp/new
```json
{
  "pathway": "node_hosting",
  "amount": 25.00,
  "chainId": 8453,
  "tokenAddress": "eth"
}
```

## GET /api/web3/onramp/{onRampId}
Returns latest quote/session payload.

## GET /api/web3/onramp/{onRampId}/quote
Returns quote details.

## POST /api/web3/onramp/{onRampId}/tx
```json
{
  "fromWallet": "0x1111111111111111111111111111111111111111",
  "txHash": "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}
```

## GET /api/web3/onramp/{onRampId}/proof
Returns proof packet:
- onRampId
- paymentRef
- proofId
- pathway
- fromWallet
- toWallet
- transactionHash
- chainId
- tokenAddress
- amount
- status
- createdAt
- updatedAt

## GET /api/web3/chains/health
Returns Base chain health response.
