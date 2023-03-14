<p style="font-style: italic">⚠️Not audited⚠️</p>

We intend to deploy a Proxy Upgradable Trustless system on every EVM-chain on the same address governed by Trustless DAO

<h1>Token Factory</h1>
<table align="center">
   <tr><td /><td>ERC20</td><td>ERC777</td><td>ERC721</td><td>1155</td></tr>
   <tr><td>Deploy</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td></tr>
   <tr><td>Deploy Wrapped</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td></tr>
</table>
Each deployment utilizes MinimumProxyContract methodology.

<h1>Token Registry</h1>
   <table>
      <tr><td>Trustlessly Registered</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td></tr>
      <tr><td>Imported as Wrapped</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td></tr>
   </table>
   
<h1>Token Trading</h1>
Essentially an internally 1155 uniswap

<h1>DAO</h1>
A modular system of governance contracts so that different requirements may be satisfied by writing simplified modules using Silidity inheritance

<h1>Token Client</h1> 
<h3>A token aggregator to develop standard-agnostic token operations</h3> 
<h3>Shared interface for functionality of ERC20, ERC721, ERC1155 or any future standard or custom token!</h3>

## 🧐 Overview

[TokenClient](contracts/TokenClient.sol) is a smart contract written in Solidity to support fungible and non-fungible token operations (such as sell/buy, swap, etc) in a generic way, making easy, quick, elegant, generic and future-proof implementations of token algorithms.

Support new standards in your logic by simply registering a contract address in the client, which inherits from [TokenAbstraction](contracts/TokenAbstraction.sol). Your code interacts with the client instead of the ERC20, ERC721, or any other instance (the client will do it for you). So you don't need to commit your code to protocols, you can focus on the fun stuff, and make more elegant dapps by eliminating redundancy where all tokens share functionality (like isApproved or transfer or balanceOf), which is the functionality that many marketplaces and complex operators need to operate with tokens.

<p align="center"><img src="./imgs/TokenClientDiagram.PNG" alt="TokenClientDiagram"></p>
 
You can reference a TokenClient instance on your dapp or inherit from TokenClient contract. To support the standards you want, you have to register them on the client using some [TokenAbstraction](contracts/TokenAbstraction.sol) concrete, such as [TokenERC20](contracts/concretes/TokenERC20.sol), [TokenERC721](contracts/concretes/TokenERC721.sol) or [TokenERC1155](contracts/concretes/TokenERC1155.sol) (or creating your own), which have a few view functions, the transfer function and doesn't have storage. These are in charge of calling the methods of each standard, but you only have to make calls to your TokenClient instance, using methods such as `isOwner`, `balanceOf`, `isApproved` or `transfer`. Then you can focus on the logic of your dapp without worrying about standards support, separating this decision from the implementation and allowing it to be defined at any time.

For complete information check the README of the Token-client branch
