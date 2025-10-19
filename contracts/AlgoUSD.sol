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

    event TargetPriceUpdated(uint256 newTargetPrice);
    event RebaseFailed(string reason);
    event MintExecuted(address to, uint256 amount);
    event BurnExecuted(address from, uint256 amount);

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

    /**
     * @dev Mint tokens (only callable through Timelock/Multisig).
     * @param to Address to receive minted tokens.
     * @param amount Amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external onlyRole(TIMELOCK_ROLE) whenNotPaused {
        _mint(to, amount);
        emit MintExecuted(to, amount);
    }

    /**
     * @dev Burn tokens (only callable through Timelock/Multisig).
     * @param from Address to burn tokens from.
     * @param amount Amount of tokens to burn.
     */
    function burn(address from, uint256 amount) external onlyRole(TIMELOCK_ROLE) whenNotPaused {
        _burn(from, amount);
        emit BurnExecuted(from, amount);
    }

    /**
     * @dev Adjust token supply to maintain the peg.
     * Fetches price from OracleAggregator and applies rebase.
     */
    function rebase() external onlyRole(TIMELOCK_ROLE) whenNotPaused {
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
            // Calculate percentage increase
            rebasePercent = ((price - targetPrice) * 100) / targetPrice;
            circuitBreaker.enforceRebaseCap(rebasePercent);

            uint256 excessSupply = totalSupply() * rebasePercent / 100;
            _mint(address(this), excessSupply);

        } else if (price < targetPrice) {
            // Calculate percentage decrease
            rebasePercent = ((targetPrice - price) * 100) / targetPrice;
            circuitBreaker.enforceRebaseCap(rebasePercent);

            uint256 requiredBurn = totalSupply() * rebasePercent / 100;
            _burn(address(this), requiredBurn);
        }

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
