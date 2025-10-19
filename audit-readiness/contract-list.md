# Contract List

## Contracts and Purpose

1. **AlgoUSD.sol**
   - Primary ERC20 token contract implementing the stablecoin logic.
   - Integrates rebase mechanics, CircuitBreaker, and OracleAggregator.

2. **OracleAggregator.sol**
   - Aggregates prices from multiple price feeds and applies median and TWAP.
   - Handles staleness checks and outlier rejection.

3. **CircuitBreaker.sol**
   - Implements caps for rebase operations.
   - Provides pause and emergency stop functionality.

---