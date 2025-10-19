// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "contracts/AlgoUSD.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title Multisig and Timelock Test Suite
 */
contract MultisigTimelockTest is Test {
    AlgoUSD public algoUSD;
    TimelockController public timelockController;

    address public timelockAdmin;
    address[] public proposers;
    address[] public executors;

    function setUp() public {
        // Set up addresses
        timelockAdmin = address(0x1);
        proposers = new address[](3);
        proposers[0] = address(0x2);
        proposers[1] = address(0x3);
        proposers[2] = address(0x4);

        executors = new address[](2);
        executors[0] = address(0x5);
        executors[1] = address(0x6);

        // Deploy TimelockController
        timelockController = new TimelockController(
            2 days,  // Minimum delay
            proposers,
            executors
        );

        // Deploy AlgoUSD contract
        algoUSD = new AlgoUSD(address(timelockController), timelockAdmin);
        assertEq(algoUSD.targetPrice(), 1 ether);
    }

    function testOnlyTimelockCanMint() public {
        vm.startPrank(address(timelockController));
        algoUSD.mint(address(0x7), 1000 ether);
        assertEq(algoUSD.balanceOf(address(0x7)), 1000 ether);
        vm.stopPrank();

        vm.startPrank(address(0x8)); // Unauthorized user
        vm.expectRevert();
        algoUSD.mint(address(0x7), 1000 ether);
        vm.stopPrank();
    }

    function testOnlyTimelockCanBurn() public {
        vm.startPrank(address(timelockController));
        algoUSD.mint(address(0x7), 1000 ether);
        algoUSD.burn(address(0x7), 500 ether);
        assertEq(algoUSD.totalSupply(), 500 ether);
        vm.stopPrank();

        vm.startPrank(address(0x8)); // Unauthorized user
        vm.expectRevert();
        algoUSD.burn(address(0x7), 500 ether);
        vm.stopPrank();
    }

    function testTimelockEnforcesDelayForRebase() public {
        uint256 simulatedPrice = 2 ether;
        bytes memory data = abi.encodeWithSelector(algoUSD.rebase.selector, simulatedPrice);

        vm.startPrank(address(timelockAdmin));
        timelockController.schedule(
            address(algoUSD),
            0,
            data,
            bytes32(0),
            bytes32(0),
            2 days
        );
        vm.stopPrank();

        // Attempt rebase before the timelock expires
        vm.startPrank(address(timelockController));
        vm.expectRevert("TimelockController: operation is not ready");
        timelockController.execute(
            address(algoUSD),
            0,
            data,
            bytes32(0),
            bytes32(0)
        );
        vm.stopPrank();

        // Advance time past the timelock
        vm.warp(block.timestamp + 2 days);

        // Execute rebase after timelock
        vm.startPrank(address(timelockController));
        timelockController.execute(
            address(algoUSD),
            0,
            data,
            bytes32(0),
            bytes32(0)
        );
        vm.stopPrank();

        assertEq(algoUSD.totalSupply(), algoUSD.totalSupply() + (algoUSD.totalSupply() * (simulatedPrice - 1 ether) / 1 ether));
    }
}