---

# AlgoUSD (AUSD) - Algorithmic Stablecoin Project

## About the Project
AlgoUSD is a decentralized ERC20 token designed to maintain a 1 USD peg using algorithmic mechanisms such as rebase and elastic supply adjustments. This stablecoin benefits from cutting-edge security and governance features, including the **Multisig + Timelock Protection** framework for critical functions.

The project employs OpenZeppelin's battle-tested libraries and is developed with assistance from **Harvey**, an advanced AI agent created by **Neural Inverse**. Harvey specializes in AI-powered software development, facilitating automated and optimized programming workflows. Learn more about Harvey at [neuralinverse.com/harvey](https://neuralinverse.com/harvey).
---

## Features
### **Core Features**
1. **Algorithmic USD Peg Maintenance**:
   - Dynamic rebase mechanism adjusts token supply based on market demand and real-time price feeds.

2. **Multisig + Timelock Governance**:
   - OpenZeppelin's `TimelockController` ensures sensitive function executions (e.g., rebase, mint, burn, target price changes) are accessible only via multisig approval and subject to time delays.

3. **Pausable Mechanisms**:
   - Admins can pause/unpause the contract during emergencies to protect users and the system.

4. **Upgradeable Architecture**:
   - Built with OpenZeppelin's `UUPSUpgradeable`, enabling secure contract upgrades for future developments.
---

## Getting Started
### Prerequisites
1. **Foundry Installation**:
