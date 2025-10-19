// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "contracts/AlgoUSD.sol";

/**
 * @title Test suite for AlgoUSD Contract
 */
contract AlgoUSDTest is Test {
    AlgoUSD public algoUSD;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x123);

        // Mock price feed address (use actual deployed contract address when testing)
        address priceFeedAddress = 0x9326BFA02ADD2366b30bacB125260Af641031331; // ETH/USD Mock price

        algoUSD = new AlgoUSD(priceFeedAddress);
    }

    function test_initialState() public {
        assertEq(algoUSD.name(), "AlgoUSD");
        assertEq(algoUSD.symbol(), "AUSD");
        assertEq(algoUSD.totalSupply(), 0);
    }

    function test_mintTokens() public {
        uint256 mintAmount = 1000 ether;

        algoUSD.mint(user, mintAmount);
        assertEq(algoUSD.balanceOf(user), mintAmount);
        assertEq(algoUSD.totalSupply(), mintAmount);
    }

    function test_burnTokens() public {
        uint256 mintAmount = 1000 ether;
        uint256 burnAmount = 500 ether;

        algoUSD.mint(user, mintAmount);
        assertEq(algoUSD.balanceOf(user), mintAmount);

        algoUSD.burn(user, burnAmount);
        assertEq(algoUSD.balanceOf(user), mintAmount - burnAmount);
        assertEq(algoUSD.totalSupply(), mintAmount - burnAmount);
    }

    function test_targetPriceUpdate() public {
        uint256 newPrice = 2 ether;
        algoUSD.setTargetPrice(newPrice);

        assertEq(algoUSD.targetPrice(), newPrice);
    }

    function test_rebaseIncreaseSupply() public {
        uint256 mintAmount = 1000 ether;
        algoUSD.mint(user, mintAmount);

        uint256 simulatedPrice = 2 ether; // Simulate a price above the target
        uint256 expectedIncrease = mintAmount * (simulatedPrice - algoUSD.targetPrice()) / algoUSD.targetPrice();

        algoUSD.rebase(simulatedPrice);

        assertEq(algoUSD.totalSupply(), mintAmount + expectedIncrease);
    }

    function test_rebaseDecreaseSupply() public {
        uint256 mintAmount = 1000 ether;
        algoUSD.mint(user, mintAmount);

        uint256 simulatedPrice = 0.5 ether; // Simulate a price below the target
        uint256 expectedBurn = mintAmount * (algoUSD.targetPrice() - simulatedPrice) / algoUSD.targetPrice();

        algoUSD.rebase(simulatedPrice);

        assertEq(algoUSD.totalSupply(), mintAmount - expectedBurn);
    }
}