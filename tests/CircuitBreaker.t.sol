// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "contracts/AlgoUSD.sol";
import "contracts/CircuitBreaker.sol";

/**
 * @title CircuitBreaker and AlgoUSD Test Suite
 */
contract CircuitBreakerTest is Test {
    AlgoUSD public algoUSD;
    CircuitBreaker public circuitBreaker;

    address public timelockAdmin;

    function setUp() public {
        // Define roles and setup
        timelockAdmin = address(this);

        circuitBreaker = new CircuitBreaker(timelockAdmin, 10); // 10% max rebase cap
        algoUSD = new AlgoUSD(address(0x100), address(circuitBreaker), timelockAdmin);
    }

    function testRebaseRespectsCap() public {
        // Mint initial supply
        vm.startPrank(timelockAdmin);
        algoUSD.mint(address(this), 1000 ether);

        uint256 largeRebasePercent = 15; // Greater than the max cap
        uint256 validRebasePercent = 5; // Within the cap

        // Simulate large rebase and expect revert
        vm.expectRevert("Rebase exceeds max allowed percent");
        circuitBreaker.enforceRebaseCap(largeRebasePercent);

        // Simulate valid rebase
        bool withinCap = circuitBreaker.enforceRebaseCap(validRebasePercent);
        assertTrue(withinCap);

        vm.stopPrank();
    }

    function testPauseAndUnpauseRebase() public {
        // Mint initial supply
        vm.startPrank(timelockAdmin);
        algoUSD.mint(address(this), 1000 ether);

        // Pause rebase
        circuitBreaker.pauseRebase();
        assertTrue(circuitBreaker.paused());

        // Rebase should fail while paused
        vm.expectRevert("Pausable: paused");
        algoUSD.rebase(2 ether);

        // Unpause and retry
        circuitBreaker.unpauseRebase();
        assertFalse(circuitBreaker.paused());
        algoUSD.rebase(2 ether); // Should execute successfully
        
        vm.stopPrank();
    }

    function testEmergencyPause() public {
        // Emergency pause
        vm.startPrank(timelockAdmin);
        circuitBreaker.emergencyPause();
        assertTrue(circuitBreaker.paused());
        vm.stopPrank();

        // All contract actions should fail
        vm.startPrank(timelockAdmin);
        vm.expectRevert("Pausable: paused");
        algoUSD.mint(address(this), 500 ether);
        vm.expectRevert("Pausable: paused");
        algoUSD.burn(address(this), 100 ether);
        vm.stopPrank();
    }

    function testDynamicRebaseCapAdjustment() public {
        uint256 initialRebaseCap = circuitBreaker.maxRebasePercentPerEpoch();
        assertEq(initialRebaseCap, 10, "Initial rebase cap should be set to 10%.");

        // Update rebase cap via governance
        vm.startPrank(timelockAdmin);
        circuitBreaker.updateMaxRebasePercentDynamic(20, true);
        vm.stopPrank();
        assertEq(circuitBreaker.maxRebasePercentPerEpoch(), 20, "Rebase cap update failed.");

        // Unauthorized update attempt
        vm.startPrank(address(0x123));
        vm.expectRevert("Caller is not authorized via governance");
        circuitBreaker.updateMaxRebasePercentDynamic(30, true);
        vm.stopPrank();

        // Admin update
        vm.startPrank(timelockAdmin);
        circuitBreaker.updateMaxRebasePercentDynamic(30, false);
        vm.stopPrank();
        assertEq(circuitBreaker.maxRebasePercentPerEpoch(), 30, "Rebase cap update failed via admin.");
    }

    function testInvalidDynamicRebaseCapValues() public {
        // Attempt to set rebase cap outside valid range
        vm.startPrank(timelockAdmin);
        vm.expectRevert("Invalid dynamic range");
        circuitBreaker.updateMaxRebasePercentDynamic(60, true);
        vm.stopPrank();
    }
}
