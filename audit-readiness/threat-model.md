# Threat Model

## Potential Vulnerabilities

### **Oracle Manipulation**
- **Risk**:
  - Malicious actors could manipulate the oracle data to force abnormal token supply changes.
- **Mitigation**:
  - Use multiple price feeds with fallback mechanisms.
  - Apply staleness checks and outlier rejection in OracleAggregator.

### **Rebase Vulnerabilities**
- **Risk**:
  - Flash-loan-style mass liquidations could destabilize token supply.
  - Rapid successive rebases may over-adjust.
- **Mitigation**:
  - Implement caps per epoch in CircuitBreaker.
  - Validate rebase percentages against caps.

### **Front-Running**
- **Risk**:
  - Front-running attacks during rebase operations could allow bad actors to exploit changes in supply.
- **Mitigation**:
  - Enforce timelock/multisig for rebase operations.
  - Ensure rebase process depends on the latest price feed data.

### **General Solidity Risks**
- **Risk**:
  - Reentrancy attacks, integer overflows/underflows, and access control bypass.
- **Mitigation**:
  - Libraries: OpenZeppelin (`AccessControl`, `Pausable`, `ReentrancyGuard`).
  - Unit testing for overflow using Foundry.

---
## Recommendations
- Regularly audit price feed sources for reliability.
- Apply external audits.
---