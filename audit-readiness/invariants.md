# Expected Invariants

## AlgoUSD Invariants

1. Total supply must remain non-negative.
2. Rebase operations must respect caps from CircuitBreaker (`maxRebasePercentPerEpoch`).
3. No overflow/underflow during any arithmetic operations.
4. Monotonicity limits respected (smooth changes in supply).
5. Contract respects pause states.

## OracleAggregator Invariants
1. Aggregated price reflects median of valid price feeds.
2. Stale feeds are excluded based on `stalenessThreshold`.
3. Outlier rejection ensures abnormal values are ignored.
---