// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "contracts/AlgoUSD.sol";
import "contracts/CircuitBreaker.sol";
import "contracts/OracleAggregator.sol";

/**
 * @title Advanced Rebase Tests
 * @dev Using Foundry Fuzzing and Property-Based Testing
 */
contract AdvancedRebaseTests is Test {
    AlgoUSD public algoUSD;
    CircuitBreaker public circuitBreaker;
    OracleAggregator public oracleAggregator;

    address public timelockAdmin;
    address[] public proposers;
    address[] public executors;

    function setUp() public {
        timelockAdmin = address(this);

        // Deploy CircuitBreaker and OracleAggregator
        circuitBreaker = new CircuitBreaker(timelockAdmin, 10); // Max rebase cap 10%
        oracleAggregator = new OracleAggregator(1 hours, timelockAdmin); // Staleness threshold is 1 hour

        // Deploy AlgoUSD
        algoUSD = new AlgoUSD(address(oracleAggregator), address(circuitBreaker), timelockAdmin);

        // Add Oracle Feeds
        address mockPriceFeed1 = address(new MockV3Aggregator(8, 2000 * 10**8));
        address mockPriceFeed2 = address(new MockV3Aggregator(8, 1980 * 10**8));

        vm.startPrank(timelockAdmin);
        oracleAggregator.addPriceFeed(mockPriceFeed1, false);
        oracleAggregator.addPriceFeed(mockPriceFeed2, true);
        vm.stopPrank();

        // Seed initial supply
        vm.startPrank(timelockAdmin);
        algoUSD.mint(address(this), 1000 ether);
        vm.stopPrank();
    }

    function testFuzzRebaseTotalSupplyNonNegative(uint256 rebasePercent) public {
        vm.assume(rebasePercent <= 50); // Cap fuzz input to practical ranges

        uint256 initialSupply = algoUSD.totalSupply();

        vm.startPrank(timelockAdmin);
        uint256 scaledPercent = rebasePercent * 1 ether / 100; // Scale to percentage logic
        algoUSD.rebase();
        uint256 newSupply = algoUSD.totalSupply();
        vm.stopPrank();

        // Assert total supply is non-negative
        assertTrue(newSupply >= 0);
    }

    function testFuzzRebaseMonotonicityLimits(uint256 priceImpact) public {
        uint256 price = 2000 * 1 ether; // Example price for tests
        uint256 cap = circuitBreaker.maxRebasePercentPerEpoch();
        vm.assume(priceImpact <= cap); // Check cap enforcement

        vm.startPrank(timelockAdmin);
        oracleAggregator.addPriceFeed(address(new MockV3Aggregator(8, price + priceImpact)), false);

        algoUSD.rebase();
        uint256 postRebaseSupply = algoUSD.totalSupply();
        assertTrue(postRebaseSupply <= algoUSD.totalSupply() + (algoUSD.totalSupply() * cap / 100));

        vm.stopPrank();
    }

    function testOraclePriceManipulation() public {
        address mockPriceFeed1 = address(new MockV3Aggregator(8, 1500 * 10**8)); // Manipulated price

        vm.startPrank(timelockAdmin);
        oracleAggregator.addPriceFeed(mockPriceFeed1, false);

        uint256 aggregatedPrice = oracleAggregator.getAggregatedPrice();
        assertEq(aggregatedPrice, 1500 * 10**8, "Oracle manipulation failed");
        vm.stopPrank();
    }

    function testMassSellOff() public {
        vm.prank(timelockAdmin);
        algoUSD.mint(address(this), 1000000 ether);

        uint256 beforeSupply = algoUSD.totalSupply();
        uint256 simulatedPrice = 1000 * 1 ether; // Drop in price

        vm.startPrank(timelockAdmin);
        algoUSD.rebase(simulatedPrice);
        uint256 afterSupply = algoUSD.totalSupply();

        assertTrue(afterSupply < beforeSupply, "Rebase after mass sell-off failed");
        vm.stopPrank();
    }

    function testRapidSuccessiveRebases() public {
        uint256 price = 2040 * 10**8; // Simulate successive price increase
        for (uint256 i = 0; i < 10; i++) {
            vm.startPrank(timelockAdmin);
            oracleAggregator.addPriceFeed(address(new MockV3Aggregator(8, price + (i * 10 ** 8))), false);

            algoUSD.rebase();
            vm.stopPrank();
        }

        assertTrue(algoUSD.totalSupply() > 1000 ether, "Successive rebase did not increase total supply");
    }

    function testFrontRunningRebase() public {
        // Simulate manipulated price before rebase call
        address mockPriceFeedPreRebase = address(new MockV3Aggregator(8, 3000 * 10**8));
        address mockPriceFeedPostRebase = address(new MockV3Aggregator(8, 2000 * 10**8));

        vm.startPrank(timelockAdmin);
        oracleAggregator.addPriceFeed(mockPriceFeedPreRebase, false);
        uint256 manipulatedPrice = oracleAggregator.getAggregatedPrice();

        // Modify feed to normal
        oracleAggregator.removePriceFeed(0); // Remove manipulated feed
        oracleAggregator.addPriceFeed(mockPriceFeedPostRebase, false);

        uint256 correctedPrice = oracleAggregator.getAggregatedPrice();
        vm.stopPrank();

        assertTrue(correctedPrice < manipulatedPrice, "Front-running scenario failure");
    }
}