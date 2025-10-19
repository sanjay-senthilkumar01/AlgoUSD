// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";


/**
 * @title CircuitBreaker

 * @dev Implements rebase caps and emergency pause functionality with configurable parameters.
 */
contract CircuitBreaker is AccessControl, Pausable {
    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public maxRebasePercentPerEpoch; // Maximum percent allowed for rebase in a single epoch
    uint256 public minRebaseInterval; // Minimum interval between rebases
    uint256 public rebaseDampeningFactor; // Dampening factor to smooth rebase changes

    uint256 private lastRebaseTimestamp; // Tracks the last rebase execution time

    event RebasePaused(bool paused);
    event CircuitBreakerTriggered();
    event MaxRebasePercentPerEpochUpdated(uint256 newMaxRebasePercent);
    event MinRebaseIntervalUpdated(uint256 newMinInterval);
    event RebaseDampeningFactorUpdated(uint256 newDampeningFactor);


    constructor(
        address admin,
        uint256 initialMaxRebasePercentPerEpoch,
        uint256 initialMinRebaseInterval,
        uint256 initialRebaseDampeningFactor
    ) {
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(TIMELOCK_ROLE, admin);

        maxRebasePercentPerEpoch = initialMaxRebasePercentPerEpoch;
        minRebaseInterval = initialMinRebaseInterval;
        rebaseDampeningFactor = initialRebaseDampeningFactor;
    }

    /**


     * @dev Updates maximum rebase percentage per epoch (Time-locked setter).
     */
    function updateMaxRebasePercentPerEpoch(uint256 newMaxRebasePercent) external onlyRole(TIMELOCK_ROLE) {
        require(newMaxRebasePercent > 0, "Invalid rebase percentage");
        maxRebasePercentPerEpoch = newMaxRebasePercent;
        emit MaxRebasePercentPerEpochUpdated(newMaxRebasePercent);
    }

    /**

     * @dev Updates minimum rebase interval (Time-locked setter).
     */



    function updateMinRebaseInterval(uint256 newMinInterval) external onlyRole(TIMELOCK_ROLE) {
        require(newMinInterval > 0, "Invalid rebase interval");
        minRebaseInterval = newMinInterval;
        emit MinRebaseIntervalUpdated(newMinInterval);
    }

    /**

     * @dev Updates rebase dampening factor (Time-locked setter).
     */



    function updateRebaseDampeningFactor(uint256 newDampeningFactor) external onlyRole(TIMELOCK_ROLE) {
        require(newDampeningFactor > 0, "Invalid dampening factor");
        rebaseDampeningFactor = newDampeningFactor;
        emit RebaseDampeningFactorUpdated(newDampeningFactor);
    }

    /**


     * @dev Enforces rebase limits based on interval.
     * Emits an error if the minimum interval has not passed.
     */



    function enforceRebaseInterval() external view whenNotPaused returns (bool) {
        require(block.timestamp >= lastRebaseTimestamp + minRebaseInterval, "Rebase interval not met");
        return true;
    }

    /**



     * @dev Updates last rebase timestamp.
     */



    function updateLastRebaseTimestamp() external onlyRole(TIMELOCK_ROLE) {
        lastRebaseTimestamp = block.timestamp;
    }
}