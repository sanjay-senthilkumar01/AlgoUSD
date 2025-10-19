// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "contracts/AlgoUSD.sol";

/**
 * @title Script to update the target price for AlgoUSD contract
 */
contract SetTargetPrice is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Replace with the actual deployed AlgoUSD contract address
        address algoUSDAddress = vm.envAddress("AUSD_CONTRACT_ADDRESS");
        uint256 newTargetPrice = vm.envUint("NEW_TARGET_PRICE");

        AlgoUSD algoUSD = AlgoUSD(algoUSDAddress);
        algoUSD.setTargetPrice(newTargetPrice);

        console.log("Target price updated to:", newTargetPrice);

        vm.stopBroadcast();
    }
}