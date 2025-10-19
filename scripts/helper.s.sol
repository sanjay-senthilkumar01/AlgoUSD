// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @dev This file contains helper functions and constants for scripts using AlgoUSD.
 */

library Helper {
    /**
     * @dev Converts wei amount to Ether
     */
    function weiToEther(uint256 weiAmount) internal pure returns (uint256) {
        return weiAmount / 1e18;
    }

    /**
     * @dev Converts Ether amount to wei
     */
    function etherToWei(uint256 etherAmount) internal pure returns (uint256) {
        return etherAmount * 1e18;
    }

    /**
     * @dev Calculates the percentage of a number
     */
    function percentage(uint256 amount, uint256 percent) internal pure returns (uint256) {
        return (amount * percent) / 100;
    }
}