// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title AlgoUSD (AUSD)
 * @dev ERC20 token pegged to USD using a smart contract algorithm
 */
contract AlgoUSD is ERC20, Ownable {
    AggregatorV3Interface public priceFeed;

    uint256 public targetPrice = 1 ether; // Target price of $1 per token (scaled)

    /**
     * @dev Constructor of the AUSD token
     * @param priceFeedAddress The address of the Chainlink price feed contract
     * @param initialOwner The initial owner of the contract
     */
    constructor(address priceFeedAddress, address initialOwner) 
        ERC20("AlgoUSD", "AUSD") 
        Ownable(initialOwner) 
    {
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    /**
     * @dev Public function to mint tokens
     * @param to Address to receive minted tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Public function to burn tokens
     * @param from Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    /**
     * @dev Adjust token supply to maintain the peg.
     * @param price Current price of AUSD from an external price feed.
     */
    function rebase(uint256 price) external onlyOwner {
        require(price > 0, "Invalid price value");

        if (price > targetPrice) {
            // Mint tokens to increase supply
            uint256 excessSupply = totalSupply() * (price - targetPrice) / targetPrice;
            _mint(address(this), excessSupply);
        } else if (price < targetPrice) {
            // Burn tokens to decrease supply
            uint256 requiredBurn = totalSupply() * (targetPrice - price) / targetPrice;
            _burn(address(this), requiredBurn);
        }
    }

    /**
     * @dev Function to set a new target price (only owner)
     * @param newTargetPrice The new target price for the algorithm
     */
    function setTargetPrice(uint256 newTargetPrice) external onlyOwner {
        require(newTargetPrice > 0, "Price must be greater than zero");
        targetPrice = newTargetPrice;
    }
}