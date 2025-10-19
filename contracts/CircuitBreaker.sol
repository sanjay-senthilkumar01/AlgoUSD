// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title CircuitBreaker
 * @dev Enforces rebase caps and manages emergency pause functionality.
 */
contract CircuitBreaker is AccessControl, Pausable {
    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public maxRebasePercentPerEpoch; // Maximum percent allowed for rebase in a single epoch

    event RebasePaused(bool paused);
    event CircuitBreakerTriggered();
    event MaxRebasePercentPerEpochUpdated(uint256 newMaxRebasePercent);

    constructor(address admin, uint256 initialMaxRebasePercentPerEpoch) {
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(TIMELOCK_ROLE, admin);

        maxRebasePercentPerEpoch = initialMaxRebasePercentPerEpoch;
    }

    /**
     * @dev Updates the maximum rebase percentage per epoch (requires TIMELOCK_ROLE).
     * @param newMaxRebasePercent The new maximum percentage for rebases.
     */
    function updateMaxRebasePercentPerEpoch(uint256 newMaxRebasePercent) external onlyRole(TIMELOCK_ROLE) {
        require(newMaxRebasePercent > 0, "Invalid rebase percentage");
        maxRebasePercentPerEpoch = newMaxRebasePercent;
        emit MaxRebasePercentPerEpochUpdated(newMaxRebasePercent);
    }

    /**
     * @dev Updates the maximum rebase percentage dynamically (requires ADMIN_ROLE or TIMELOCK_ROLE based on governance process).
     * @param newMaxRebasePercent The new maximum percentage for rebases.
     * @param viaGovernance Boolean value indicating whether the update is via governance.
     */
    function updateMaxRebasePercentDynamic(uint256 newMaxRebasePercent, bool viaGovernance) external {
        if (viaGovernance) {
            require(hasRole(TIMELOCK_ROLE, msg.sender), "Caller is not authorized via governance");
        } else {
            require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not authorized as admin");
        }

        require(newMaxRebasePercent > 0 && newMaxRebasePercent <= 50, "Invalid dynamic range");
        maxRebasePercentPerEpoch = newMaxRebasePercent;
        emit MaxRebasePercentPerEpochUpdated(newMaxRebasePercent);
    }

    /**
     * @dev Pauses rebase functionality (requires TIMELOCK_ROLE).
     */
    function pauseRebase() external onlyRole(TIMELOCK_ROLE) {
        _pause();
        emit RebasePaused(true);
    }

    /**
     * @dev Unpauses rebase functionality (requires TIMELOCK_ROLE).
     */
    function unpauseRebase() external onlyRole(TIMELOCK_ROLE) {
        _unpause();
        emit RebasePaused(false);
    }

    /**
     * @dev Triggers a circuit breaker for emergency situations.
     * This pauses all operations on the contract.
     */
    function emergencyPause() external onlyRole(ADMIN_ROLE) {
        _pause();
        emit CircuitBreakerTriggered();
    }

    /**
     * @dev Ensures the rebase percentage does not exceed the configured maximum.
     * Can only be used internally.
     * @param rebasePercent Proposed percentage for rebase.
     */
    function enforceRebaseCap(uint256 rebasePercent) external view whenNotPaused returns (bool) {
        require(rebasePercent <= maxRebasePercentPerEpoch, "Rebase exceeds max allowed percent");
        return true;
    }
}
