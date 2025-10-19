# AlgoUSD (AUSD) - Algorithmic Stablecoin Project

## About the Project
AlgoUSD is a decentralized ERC20 token designed to maintain a 1 USD peg using algorithmic mechanisms such as rebase and elastic supply adjustments. This stablecoin benefits from cutting-edge security and governance features, including the **Multisig + Timelock Protection** framework for critical functions.

The project employs OpenZeppelin's battle-tested libraries and is developed using AI-powered assistance from Harvey, an advanced AI agent created by **Neural Inverse**. Learn more about Harvey at [neuralinverse.com/harvey](https://neuralinverse.com/harvey).

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
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Node.js Dependencies**:
   - Install required modules:
   ```bash
   npm install
   ```

### Deployment Instructions
1. Set up environment variables:
    ```bash
    export PRIVATE_KEY="<your-private-key>"
    export PRICE_FEED_ADDRESS="<chainlink-price-feed-contract-address>"
    export INITIAL_OWNER_ADDRESS="<timelock-admin-address>"
    export TIMELOCK_ADMIN="<timelock-admin-address>"
    export MULTISIG_SIGNER_1="<address-1>"
    export MULTISIG_SIGNER_2="<address-2>"
    export MULTISIG_SIGNER_3="<address-3>"
    export MULTISIG_SIGNER_4="<address-4>"
    export MULTISIG_SIGNER_5="<address-5>"
    ```

2. Run Foundry Deployment Script:
    ```bash
    forge script scripts/deploy_algoUSD.s.sol --broadcast --rpc-url <RPC_URL> --verifier etherscan
    ```
3. Verify the deployment by fetching the deployed addresses of `AlgoUSD` and `TimelockController` contracts.

---

## Documentation
Detailed documentation is available in the [`docs`](docs/) folder.

Highlights of the repository:
- **Detailed Workflow**:
    - Explains features such as governance, role-based access, and ways to configure timelock.
    - Shows how to change multisig signers and complete operations.
    
- **Contributions**:
    - Guidelines for contributing to the development of AlgoUSD.

For additional explanations: [View Documentation](docs/README.md).

---

## Contributing
We welcome contributions aimed at improving AlgoUSD:
1. Fork this repository.
2. Implement changes along with test cases.
3. Submit a well-described Pull Request.

Please check out our **Issues Tracker** under [GitHub Issues](https://github.com/sanjay-senthilkumar01/AlgoUSD/issues) for bug reporting and discussing feature requests.

---

## License
This project is licensed under the [MIT License](LICENSE).

---

### Learn More
Developed by **Neural Inverse**'s Harvey AI Agent. For details, visit [neuralinverse.com/harvey](https://neuralinverse.com/harvey).
