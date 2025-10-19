# Summarized Changelog

## Version Update Summary

### **v2.0.0** (Current)
1. **Added Multisig + Timelock integration**:
   - Owner-only functions now governed by Timelock/Multisig.
   - Functions: `mint`, `burn`, `rebase`, `setTargetPrice`, `pause/unpause`.

2. **Implemented OracleAggregator**:
   - Median/TWAP logic.
   - Staleness checks and fallback price feeds.
   - Outlier rejection to ensure price reliability.

3. **Integrated CircuitBreaker**:
   - Caps rebase percentage changes.
   - Supports pause/unpause functionality for rebases.
   - Emergency stop functionality.

4. **Enhanced Test Suite**:
   - Foundry fuzzing and adversarial test cases for core functionality.
   - Included Oracle manipulation simulation and flash-loan testing.

5. **Created CI Pipeline**:
   - Automated linter (Solhint), Foundry/Hardhat tests, TypeScript tests.
   - Integrated Slither static analysis for vulnerability detection.

---