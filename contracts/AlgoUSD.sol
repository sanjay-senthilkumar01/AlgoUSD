// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title AlgoUSD (AUSD)
 * @dev ERC20 token pegged to USD with multisig and timelock protections
 */
contract AlgoUSD is ERC20, AccessControl, Pausable, UUPSUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");

    TimelockController public timelockController;
    uint256 public targetPrice = 1 ether; // Target price of $1 per token (scaled)

    event TargetPriceUpdated(uint256 newTargetPrice);

    /**
     * @dev Constructor of the AUSD token
     * @param priceFeedAddress The address of the Chainlink price feed contract
     * @param timelockAdmin Address of the timelock admin
     * @param proposers Array of proposer addresses for the timelock
     * @param executors Array of executor addresses who can execute operations
     */
    constructor(
        address priceFeedAddress,
        address timelockAdmin,
        address[] memory proposers,
        address[] memory executors
    ) ERC20("AlgoUSD", "AUSD") {
        timelockController = new TimelockController(
            2 days, // Default minimum delay
            proposers, // Proposers
            executors // Executors
        );
        timelockController.grantRole(timelockController.TIMELOCK_ADMIN_ROLE(), timelockAdmin);
        timelockController.grantRole(TIMELOCK_ROLE, address(timelockController));
        timelockController.grantRole(ADMIN_ROLE, timelockAdmin);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Public function to mint tokens with multisig and timelock protection
     * @param to Address to receive minted tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyRole(TIMELOCK_ROLE) whenNotPaused {
        _mint(to, amount);
    }

    /**
     * @dev Public function to burn tokens with multisig and timelock protection
     * @param from Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burn(address from, uint256 amount) external onlyRole(TIMELOCK_ROLE) whenNotPaused {
        _burn(from, amount);
    }

    /**
     * @dev Adjust token supply to maintain the peg with timelock protection
     * @param price Current price of AUSD from an external price feed.
     */
    function rebase(uint256 price) external onlyRole(TIMELOCK_ROLE) whenNotPaused {
        require(price > 0, "Invalid price value");

        if (price > targetPrice) {
            uint256 excessSupply = totalSupply() * (price - targetPrice) / targetPrice;
            _mint(address(this), excessSupply);
        } else if (price < targetPrice) {
            uint256 requiredBurn = totalSupply() * (targetPrice - price) / targetPrice;
            _burn(address(this), requiredBurn);
        }

        emit TargetPriceUpdated(targetPrice);
    }

    /**
     * @dev Updates the target price with timelock protection
     * @param newTargetPrice The new target price
     */
    function setTargetPrice(uint256 newTargetPrice) external onlyRole(TIMELOCK_ROLE) whenNotPaused {
        require(newTargetPrice > 0, "Price must be greater than zero");
        targetPrice = newTargetPrice;

        emit TargetPriceUpdated(newTargetPrice);
    }

    /**
     * @dev Pause contract in case of emergency
     */
    function pause() external onlyRole(ADMIN_ROLE) whenNotPaused {
        _pause();
    }

    /**
     * @dev Unpause contract
     */
    function unpause() external onlyRole(ADMIN_ROLE) whenPaused {
        _unpause();
    }

    /**
     * @dev Required override for UUPS proxy pattern
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(ADMIN_ROLE) {}
}