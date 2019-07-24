---
layout: post
title:  "Zero Knowledge API Keys"
author: nirmal
categories: [ technology ]
image: assets/images/zka.png
featured: true
hidden: true
---

### Zero Knowledge API Keys

API keys enable low-risk delegation of restricted sets of capabilities to other apps or users. On an exchange, a read-only API key can be used for portfolio tracking. A trade-only API key can be used with a trading app. This enables the use of powerful tools without the fear of total loss of funds.

Market makers and institutions are required to separate trading and custodial responsibilities due to regulatory and control requirements. It’s unsafe to place a private key that controls a large market maker account on a cloud server. It’s also impractical to give private keys to individual traders and hope they act responsibly. This would be a controls failure and a violation of custodial separation laws in many jurisdictions.

For the above reasons, an exchange (including DEX) without functional API keys would find it extremely hard to attract institutional size volume.

#### API Keys on Centralized Platforms

A server and a client agree on a shared secret (API Secret) identified by an API Key. The API secret is used by a message sender to produce a message authentication code ([HMAC](https://en.wikipedia.org/wiki/HMAC),) sent along with the message. The receiver looks up the API secret using the API Key and is able to validate message integrity from the HMAC.

#### The Dire API Key Situation on DEXs

On DEXs and other decentralized platforms, there is no place to keep shared secrets since every message and smart contract state is public. This has led to DEX users having to trade directly from their wallet, choosing between exposure of funds on an online/in-browser wallet or the inconvenience of having to unlock/operate a hardware wallet for every action.

The current DEX situation is a cry for decentralized API keys: in-browser keys that can view/trade but cannot move funds.

#### Zero Knowledge API Keys

[Public key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography) is a fundamental component of blockchains and is a natural solution for decentralized API keys.

The idea is simple: The Ethereum address and private key that control your funds is your _account key_ and is the only key that can be used to withdraw funds. An API key is simply _a different Ethereum address_ that has been signed with your account key to assign other capabilities to it. These API keys can perform a restricted set of operations on any smart contract on behalf of the account.

The above scheme has notable benefits. In addition to solving the UX problem, it also provides a clean audit history and provable compliance. By ensuring that all user actions are directly or indirectly traceable to a signature from the private key that controls user funds, we can prove that every operation by the exchange was authorized by the user. This includes everything from accepting terms and conditions, trading actions and deposits/withdrawals.

#### The Smart (Contract) Way

We use an API key registry contract to track user API key ownership and rights. Users register API keys with a Registry Smart Contract on the Ethereum network. This Smart Contract maps API keys to user accounts and capabilities assigned to each API key as shown by the [Registry Contract](https://ropsten.etherscan.io/address/0x5b40e4bd0d25df2b08cd0bf98cc9841ba8d9aca4) deployed on the Ethereum Ropsten Network.

![](/assets/images/zka-registry-ropten.png)

{:.image-caption} 
Registry Smart Contract on Ropsten

#### Technical Details

![](/assets/images/zka-tech-details.png)

{:.image-caption}
Account and API Key Workflow

#### Registering Account with Trading Platform

Let us consider a user with account id 0x167cdb1a…8282 signing up for Leverj. If he’s a Metamask user, he would see a prompt for the user to sign the user agreement. Other wallet users would follow their respective workflows.

![](/assets/images/zka-metamask-tnc-sign.png)

{:.image-caption}
Signing of Terms and Conditions to Create an Account with Exchange


The browser sends the following signed message to the server:
``` javascript
POST /api/v1/auth HTTP/1.1   
Host: localhost:9000  
[  
  {  
    "message": "{\"account\":\"0x167cdb1aC9979A6a694B368ED3D2bF9259Fa8282\",\"country\":\"DK\",\"timestamp\":1520571411498,\"ip\":\"127.0.0.1\"}",  
    "signature": "0x94daa4ade209f72b0ad8d6f78fc939d8e937b56920c66ba9077c6ccf9d943fc773821775672398d576600369c9ea3557860f53863a796c320ae668c7ab7f50dc1b"  
  }  
]
```

The server validates the user’s signature and creates an account with the users Ethereum address.

#### API Key Generation

The browser then creates an API key using web3 library.

The resulting key should be saved by the user and may look like this:
```json
{  
  "address": "0x202a093BEaa3b1e52C393Ea2c4e2C935B48c0b8e",  
  "secret": "0xb98ea45b6515cbd6a5c39108612b2cd5ae184d5eb0d72b21389a1fe6db01fe0d"  
}
```

The API secret is never sent over the network and the API key represented by the Ethereum address does not have access to a user’s funds. It only authorizes trading actions.

#### API Key Registration

The user sends API key address to registry contract.

```javascript
registryContract.methods  
           .register("0x202a093BEaa3b1e52C393Ea2c4e2C935B48c0b8e")  
           .send({from:"0x167cdb1aC9979A6a694B368ED3D2bF9259Fa8282"})
```

![](/assets/images/zka-metamask-register-apiktey.png)

{:.image-caption}
Submitting API Key to Registry Contract

![](/assets/images/zka-etherscan-register-tx.png)

{:.image-caption}
Snippet from Etherscan of Register Transaction

#### API Key Usage

The API key secret is stored in the browser’s local storage, and all requests to the server are signed using this key.

Here’s an example request header sent to server:


```bash
GET /api/v1/account HTTP/1.1  
Host: localhost:9000  
Connection: keep-alive  
Nonce: 1520572149481  
Authorization: SIGN 0x167cdb1aC9979A6a694B368ED3D2bF9259Fa8282.0x202a093BEaa3b1e52C393Ea2c4e2C935B48c0b8e.27.0x677bece319233856beac0705b45450c5ae2d3f82ceee3fcd498c53b3db9d136e.0x60bf13a94bceead56d901e5b5436b58c9610648b34fafa946032d2b92668218d
```
Here is a description of the Authorization header for further illustration:

<pre>
<b>User's Account Ethereum Address:</b> 0x167cdb1aC9979A6a694B368ED3D2bF9259Fa8282
<B>API Key address:</B> 0x202a093BEaa3b1e52C393Ea2c4e2C935B48c0b8e
<B>Signature (v "." r "." s) using Api Secret:</B> 27.0x677bece319233856beac0705b45450c5ae2d3f82ceee3fcd498c53b3db9d136e.0x60bf13a94bceead56d901e5b5436b58c9610648b34fafa946032d2b92668218d
</pre>

This enables a secure communication between user and server using API keys without a need to create sessions or cookies.

#### Wrapping It Up!

Zero-Knowledge API keys resolve the safety issues with DEX trading and enable market making bots, portfolio viewers and many other applications while improving UX on browsers and other client interfaces. We hope that our attention to usability and thorough understanding of what our users need helps to illustrate our commitment to making Leverj the premier crypto trading platform.
