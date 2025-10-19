# Access Matrix

## Roles and Permissions

### **AlgoUSD.sol**
- **ADMIN_ROLE**:
  - Can pause/unpause contract.
  - Can authorize upgrades.

- **TIMELOCK_ROLE**:
  - Can execute `mint`.
  - Can execute `burn`.
  - Can execute `rebase`.
  - Can update `targetPrice`.

- **DEFAULT_ADMIN_ROLE**:
  - Reserved for broader governance and ownership decisions.

### **OracleAggregator.sol**
- **ADMIN_ROLE**:
  - Can set staleness threshold.
  - Can add/remove price feeds.

### **CircuitBreaker.sol**
- **ADMIN_ROLE**:
  - Can trigger emergency pause.

- **TIMELOCK_ROLE**:
  - Can enforce rebase caps.
  - Can pause/unpause rebases.

---