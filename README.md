# Token Client & Factory

*⚠️ Not audited*
We intend to deploy a proxy upgradable trustless system on every EVM chain at the same address governed by the Trustless DAO.

## Table of Contents
- [Features](#features)
- [Token Client](#token-client)
- [Monolithic Token Factory](#monolithic-token-factory)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

In ERC1155WithERC20.sol, token ID 0 is a standard ERC-1155 token — it also implements the ERC-20-style interface and semantics on top of it. Here’s how that works conceptually:

🧩 1. Token 0 is a normal ERC-1155 ID

It exists in the same mapping structure as all other tokens:

mapping(uint256 => mapping(address => uint256)) private _balances;


So internally, balanceOf(account, 0) behaves the same as any other balanceOf(account, id).

⚙️ 2. ERC-20 compatibility is layered over it

The contract aliases the ERC-20 functions to the ERC-1155 logic for ID 0:

ERC-20 call	What it actually does
balanceOf(address)	returns balanceOf(address, 0)
transfer(to, amount)	calls _safeTransferFrom(msg.sender, to, 0, amount, "")
approve(spender, amount)	stores allowance data for token 0 only
allowance(owner, spender)	returns allowance for token 0
transferFrom(from, to, amount)	same as ERC-1155 transfer for id 0

That way:

Wallets or DEXs expecting an ERC-20 can interact with token 0 directly.

Dapps using ERC-1155 calls can still treat token 0 like any other ID.

🔄 3. Effectively: one storage model, two interfaces

The ERC-1155 implementation provides the single storage + transfer system.
The ERC-20 compatibility functions simply point to token 0 in that same system.
No duplication — just a unified structure.

✅ 4. Practical advantage

This means:

No code path divergence for ID 0 — security and balance logic are consistent.

You can mint, burn, and transfer token 0 using ERC-1155 functions, and everything stays in sync with ERC-20 views.

It’s easy to integrate with both marketplaces (ERC-1155) and DeFi (ERC-20).

## Features
### Token Factory
|               | ERC20 | ERC777 | ERC721 | 1155 |
|---------------|:----:|:----:|:----:|:----:|
| Deploy        | ✓ | ✓ | ✓ | ✓ |
| Deploy Wrapped| ✓ | ✓ | ✓ | ✓ |

Each deployment utilizes MinimumProxyContract methodology.

### Token Registry
|                     | ERC20 | ERC777 | ERC721 | 1155 |
|---------------------|:----:|:----:|:----:|:----:|
| Trustlessly Registered | ✓ | ✓ | ✓ | ✓ |
| Imported as Wrapped    | ✓ | ✓ | ✓ | ✓ |

### Token Trading
[Niftyswap](https://github.com/0xsequence/niftyswap)

### DAO
A modular system of governance contracts so that different requirements may be satisfied by writing simplified modules using Solidity inheritance.

## Token Client
### Overview
[TokenClient](contracts/TokenClient.sol) is a smart contract written in Solidity to support fungible and non‑fungible token operations (such as sell/buy, swap, etc.) in a generic way, enabling elegant and future‑proof implementations of token algorithms.

Support new standards in your logic by simply registering a contract address in the client, which inherits from [TokenAbstraction](contracts/TokenAbstraction.sol). Your code interacts with the client instead of directly with ERC20, ERC721 or any other instance. This reduces redundancy when multiple standards share functionality such as `isApproved`, `transfer` or `balanceOf`.

![Token Client Diagram](./imgs/TokenClientDiagram.PNG)

You can reference a TokenClient instance in your dapp or inherit from the TokenClient contract. To support the standards you want, register them on the client using a concrete implementation such as [TokenERC20](contracts/concretes/TokenERC20.sol), [TokenERC721](contracts/concretes/TokenERC721.sol) or [TokenERC1155](contracts/concretes/TokenERC1155.sol).

## Monolithic Token Factory
The repository includes a `MonolithicTokenFactory` capable of deploying ERC20, ERC721 and ERC1155 tokens. All tokens minted through the factory are mirrored into a single ERC1155 contract so they can be handled generically. Each deployment receives unique 1155 ids ensuring transfers stay synchronized across standards.

## Installation
Clone the repository and install the dependencies:
```bash
git clone <repo-url>
cd Tokens
npm install
```

## Usage
Compile and test the contracts using Hardhat:
```bash
npx hardhat compile
npx hardhat test
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the ISC license. See `package.json` for details.
