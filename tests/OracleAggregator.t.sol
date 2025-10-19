// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "contracts/OracleAggregator.sol";
import "@chainlink/contracts/src/v0.8/testing/MockV3Aggregator.sol";

/**
 * @title Oracle Aggregator Test Suite
 */
contract OracleAggregatorTest is Test {
    OracleAggregator public oracleAggregator;
    MockV3Aggregator public primaryFeed;
    MockV3Aggregator public fallbackFeed;

    address public admin;

    function setUp() public {
        admin = address(this);

        // Deploy mock price feeds
        primaryFeed = new MockV3Aggregator(8, 2000 * 10 ** 8); // Price: $2000
        fallbackFeed = new MockV3Aggregator(8, 1900 * 10 ** 8); // Price: $1900

        // Deploy OracleAggregator
        oracleAggregator = new OracleAggregator(1 hours, admin);
        oracleAggregator.addPriceFeed(address(primaryFeed), false); // Primary
        oracleAggregator.addPriceFeed(address(fallbackFeed), true); // Fallback
    }

    function testMedianPriceCalculation() public {
        uint256 aggregatedPrice = oracleAggregator.getAggregatedPrice();
        assertEq(aggregatedPrice, 1950 * 10 ** 8); // Median of 2000 and 1900
    }

    function testStalenessCheck() public {
        // Advance mock time for the primary feed
        vm.warp(block.timestamp + 2 hours);
        
        // Verify that staleness check removes the stale price
        uint256 aggregatedPrice = oracleAggregator.getAggregatedPrice();
        assertEq(aggregatedPrice, 1900 * 10 ** 8); // Fallback price, because primary is stale
    }

    function testFallbackBehavior() public {
        // Set mock price for primary feed
        primaryFeed.updateAnswer(1800 * 10 ** 8);
        fallbackFeed.updateAnswer(1700 * 10 ** 8);

        // Ensure fallback price is correctly aggregated
        uint256 aggregatedPrice = oracleAggregator.getAggregatedPrice();
        assertEq(aggregatedPrice, 1750 * 10 ** 8); // Median of 1800 and 1700
    }

    function testInvalidFeeds() public {
        // Set invalid prices in feeds
        primaryFeed.updateAnswer(-1); // Invalid
        fallbackFeed.updateAnswer(-1); // Invalid

        // Expect revert due to no valid price feeds
        vm.expectRevert("No valid price feeds available.");
        oracleAggregator.getAggregatedPrice();
    }

    function testStalenessThresholdUpdate() public {
        vm.startPrank(admin);
        oracleAggregator.setStalenessThreshold(2 hours);
        assertEq(oracleAggregator.stalenessThreshold(), 2 hours);
        vm.stopPrank();

        vm.startPrank(address(0x123));
        vm.expectRevert("AccessControl: account \x123 is missing role");
        oracleAggregator.setStalenessThreshold(3 hours);
        vm.stopPrank();
    }
}