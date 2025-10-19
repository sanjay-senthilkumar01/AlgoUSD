// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "contracts/CircuitBreaker.sol";
import "contracts/OracleAggregator.sol";

/**
 * @title AlgoUSD (AUSD)
 * @dev ERC20 token pegged to USD using a smart contract algorithm
 */
contract AlgoUSD is ERC20, AccessControl, Pausable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");

    OracleAggregator public oracleAggregator;
    CircuitBreaker public circuitBreaker;
    uint256 public targetPrice = 1 ether; // Target price of $1 per token (scaled)

    uint256 public minRebaseInterval; // Minimum interval between rebase operations.
    uint256 public maxRebasePercentPerEpoch; // Maximum rebase percentage allowed in a single epoch.
    uint256 public rebaseDampeningFactor; // Dampening factor to smooth changes over epochs.

    uint256 private lastRebaseTimestamp;

    event TargetPriceUpdated(uint256 newTargetPrice);
    event RebaseFailed(string reason);
    event MintExecuted(address to, uint256 amount);
    event BurnExecuted(address from, uint256 amount);
    event RebaseConfigurationUpdated(uint256 minInterval, uint256 maxPercent, uint256 dampening);

    /**
     * @dev Constructor of the AUSD token
     * @param oracleAggregatorAddress Address of the OracleAggregator contract
     * @param circuitBreakerAddress Address of the CircuitBreaker contract
     * @param initialOwner The initial admin address
     */
    constructor(
        address oracleAggregatorAddress,
        address circuitBreakerAddress,
        address initialOwner
    ) ERC20("AlgoUSD", "AUSD") {
        oracleAggregator = OracleAggregator(oracleAggregatorAddress);
        circuitBreaker = CircuitBreaker(circuitBreakerAddress);

        _grantRole(ADMIN_ROLE, initialOwner);
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(TIMELOCK_ROLE, initialOwner);
    }









        // Set safe initial rebase parameters
        minRebaseInterval = 86400; // 1 day
        maxRebasePercentPerEpoch = 5; // Maximum 5% per epoch
        rebaseDampeningFactor = 2; // Reduce rebase impact by 50%

        lastRebaseTimestamp = block.timestamp;
    }

    /**



     * @dev Updates rebase configuration parameters (requires ADMIN_ROLE).
     * @param minInterval Minimum interval between successive rebases.
     * @param maxPercent Maximum rebase percentage allowed per epoch.
     * @param dampening Dampening factor for rebases.
     */



    function updateRebaseParameters(
        uint256 minInterval,
        uint256 maxPercent,
        uint256 dampening
    ) external onlyRole(ADMIN_ROLE) {
        require(minInterval > 0, "Min rebase interval must be positive.");
        require(maxPercent > 0 && maxPercent <= 100, "Invalid max rebase percent.");
        require(dampening > 0 && dampening <= 100, "Invalid dampening factor.");

        minRebaseInterval = minInterval;
        maxRebasePercentPerEpoch = maxPercent;
        rebaseDampeningFactor = dampening;

        emit RebaseConfigurationUpdated(minInterval, maxPercent, dampening);
    }

    /**
     * @dev Adjust token supply to maintain the peg.
     * Fetches price from OracleAggregator and applies rebase.
     */
    function rebase() external onlyRole(TIMELOCK_ROLE) whenNotPaused {
        require(
            block.timestamp >= lastRebaseTimestamp + minRebaseInterval,
            "Rebase interval has not elapsed."
        );

        uint256 price;
        try oracleAggregator.getAggregatedPrice() returns (uint256 fetchedPrice) {
            price = fetchedPrice;
        } catch {
            emit RebaseFailed("OracleAggregator failed to fetch price");
            return;
        }

        if (price == 0) {
            emit RebaseFailed("Fetched price is zero");
            return;
        }

        uint256 rebasePercent;

        if (price > targetPrice) {


            // Calculate percentage increase with dampening
            rebasePercent = (((price - targetPrice) * 100) / targetPrice) / rebaseDampeningFactor;
            circuitBreaker.enforceRebaseCap(rebasePercent);

            uint256 excessSupply = totalSupply() * rebasePercent / 100;
            _mint(address(this), excessSupply);

        } else if (price < targetPrice) {


            // Calculate percentage decrease with dampening
            rebasePercent = (((targetPrice - price) * 100) / targetPrice) / rebaseDampeningFactor;
            circuitBreaker.enforceRebaseCap(rebasePercent);

            uint256 requiredBurn = totalSupply() * rebasePercent / 100;
            _burn(address(this), requiredBurn);
        }

        lastRebaseTimestamp = block.timestamp;

        emit TargetPriceUpdated(targetPrice);
    }

    /**
     * @dev Updates the target price for the stablecoin (requires TIMELOCK_ROLE).
     * @param newTargetPrice The new target price.
     */
    function setTargetPrice(uint256 newTargetPrice) external onlyRole(TIMELOCK_ROLE) whenNotPaused {
        require(newTargetPrice > 0, "Price must be greater than zero");
        targetPrice = newTargetPrice;

        emit TargetPriceUpdated(newTargetPrice);
    }

    /**
     * @dev Pauses contract actions for emergency.
     */
    function pause() external onlyRole(ADMIN_ROLE) whenNotPaused {
        circuitBreaker.emergencyPause();
    }

    /**
     * @dev Unpauses contract actions.
     */
    function unpause() external onlyRole(ADMIN_ROLE) whenPaused {
        circuitBreaker.unpauseRebase();
    }
}
