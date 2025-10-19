# AlgoUSD (AUSD) Stablecoin Documentation

## Project Overview
AlgoUSD (AUSD) is a production-grade ERC20 algorithmic stablecoin aiming to maintain a stable value pegged to USD using advanced smart contract algorithms. It incorporates security features like Multisig + Timelock mechanisms, robust access control, pause/unpause capabilities, and upgradeability patterns.

---

## **Features**
### **Core Features**
1. **ERC20 Compliance**
   - Fully compliant with ERC20 standard.
   - Built using OpenZeppelin libraries for security and quality.

2. **Multisig + Timelock Protection**
   - Owner-only functions such as `mint`, `burn`, `rebase`, `setTargetPrice`, and `pause/unpause` are protected by OpenZeppelin's `TimelockController`.
   - A 3-of-5 multisig pattern is used for proposers and executors.

3. **Elastic Rebase Mechanism**
   - Token supply dynamically adjusts in response to price feed movements to maintain the USD peg.
   - Limits extreme rebase operations for stability.

4. **Upgradeability**
   - The contract is upgradeable using the UUPS proxy standard to ensure secure iterative improvements.

5. **Pause/Unpause Safety Mechanism**
   - Admins can pause/unpause contract operations in response to emergencies.

---

## **Contract Details**
### **Roles**
1. **ADMIN_ROLE**
   - Responsible for pausing/unpausing and authorizing contract upgrades.
2. **TIMELOCK_ROLE**
   - Assigned to the TimelockController to manage sensitive owner-only operations.
   - Functions like `mint`, `burn`, `rebase`, and `setTargetPrice` are protected by this role.

### **Key Functions**
1. **mint(address to, uint256 amount)**
   - Mints tokens to the specified address.
   - Requires `TIMELOCK_ROLE`.

2. **burn(address from, uint256 amount)**
   - Burns tokens from the specified address.
   - Requires `TIMELOCK_ROLE`.

3. **rebase(uint256 price)**
   - Adjusts token supply based on price feed data to maintain USD peg.
   - Requires `TIMELOCK_ROLE`.
   - Enforces a timelock delay.

4. **setTargetPrice(uint256 newTargetPrice)**
   - Updates the target price for the stablecoin.
   - Requires `TIMELOCK_ROLE`.

5. **pause()** and **unpause()**
   - Allows admins with `ADMIN_ROLE` to pause/unpause contract operations in emergencies.

6. **upgradeTo(address newImplementation)**
   - Authorizes contract upgrades.
   - Requires `ADMIN_ROLE`.

---

## **Deployment Documentation**
### **Prerequisites**
1. Install **Foundry**:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```
2. Install project dependencies:
   ```bash
   npm install
   ```

### **Deployment Configuration**
Set necessary environment variables:
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

### **Running the Deployment Script**
```bash
forge script scripts/deploy_algoUSD.s.sol --broadcast --rpc-url <RPC_URL>
```
After deployment, you can retrieve the deployed contract addresses for both `AlgoUSD` and `TimelockController`.

---

## **Usage Instructions**
### Multisig Details
- The `TimelockController` will enforce delays on sensitive operations.
- Multisig signers act as proposers or executors.
- To change multisig signers:
  1. Use the `grantRole()` and `revokeRole()` functions from the `TimelockController`.
  
  Example:
  ```
  timelockController.grantRole(TIMELOCK_ROLE, newSignerAddress);
  timelockController.revokeRole(TIMELOCK_ROLE, oldSignerAddress);
  ```

### Verifying Timelock
- Call `timelockController.getMinDelay()` to confirm the delay.
- Call `timelockController.isOperationReady(operationId)` to check if a scheduled operation can be executed.

### Governance
- Initialize a governance mechanism by integrating OpenZeppelin's `Governor` with the `TimelockController`.
- Parameters like `targetPrice` updates and treasury policy are controlled through DAO proposals.

### Testing Deployment
Run the deployments and execute scripts:
```bash
forge test --match-path tests/MultisigTimelock.t.sol -vv
```

---

### **Future Work**
1. Add cross-chain compatibility.
2. Integrate staking functionality.
3. Perform external audits from OpenZeppelin/Certik.

---

For development updates and contributions:
[AlgoUSD GitHub Repository](https://github.com/sanjay-senthilkumar01/AlgoUSD)