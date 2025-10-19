---

# Hardhat 3 Beta Project with AlgoUSD (AUSD) Smart Contract

This project showcases a Hardhat 3 Beta setup using the native Node.js test runner (`node:test`) and the `viem` library for Ethereum interactions. Additionally, it includes the implementation of the AlgoUSD (AUSD) smart contract, an algorithmic ERC20 token designed to maintain a price peg equivalent to 1 USD.

To learn more about Hardhat 3 Beta, visit the [Getting Started guide](https://hardhat.org/docs/getting-started#getting-started-with-hardhat-3) or share feedback via the [Hardhat 3 Beta Telegram group](https://hardhat.org/hardhat3-beta-telegram-group) or [GitHub issue tracker](https://github.com/NomicFoundation/hardhat/issues/new).

---
## Project Overview

### Features from Hardhat 3 Beta
1. A simple Hardhat configuration file compatible with Hardhat 3 Beta.
2. Foundry-compatible Solidity unit tests.
3. TypeScript integration tests using `node:test`, the new Node.js native test runner, and `viem`.
4. Examples demonstrating how to connect to various networks, including locally simulating OP mainnet.

### AlgoUSD ERC20 Token
AlgoUSD (AUSD) is an **algorithmic stablecoin** implemented as an ERC20 contract. It dynamically adjusts its supply using the **rebase mechanism**, ensuring the token stays pegged to 1 USD. Key features include:
1. **ERC20 Compliance**: Leverages OpenZeppelin libraries for security and standardization.
2. **Rebase Mechanism**: Elastic changes in token supply based on price fluctuations.
3. **Oracle Integration**: Utilizes Chainlink price feeds for reliable external price data.
4. **Governance-Controlled Parameters**: Includes owner-only functions for minting, burning, and target price adjustment.

---

## Folder Structure

### Contracts
- `AlgoUSD.sol`: ERC20 implementation with rebase and oracle integration.

### Scripts
- `deploy_algoUSD.s.sol`: Deploys the AlgoUSD contract using Foundry.
- `rebase_algoUSD.s.sol`: Performs rebasing of tokens to maintain the price peg.
- `mint_algoUSD.s.sol`: Mints new AUSD tokens.
- `burn_algoUSD.s.sol`: Burns existing AUSD tokens.
- `set_target_price.s.sol`: Updates the algorithm's target price.
- `helper.s.sol`: Provides utilities like managing decimals and percentages.

### Tests
- `AlgoUSD.t.sol`: Validates key functionalities including:
  - Initial contract deployment.
  - Token minting and burning mechanics.
  - Rebase mechanism.
  - Governance-controlled functions.
  - Event logging (e.g., `Transfer`).

---

## Usage

### Install Dependencies
1. Clone the repository:

