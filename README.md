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
Essentially an internally 1155 Uniswap.

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
