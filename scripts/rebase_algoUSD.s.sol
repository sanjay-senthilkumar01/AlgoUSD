// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "contracts/AlgoUSD.sol";

/**
 * @title Script to perform rebase on AlgoUSD contract
 */
contract RebaseAlgoUSD is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Replace with the actual deployed AlgoUSD contract address
        address algoUSDAddress = vm.envAddress("AUSD_CONTRACT_ADDRESS");
        uint256 price = vm.envUint("CURRENT_PRICE");

        AlgoUSD algoUSD = AlgoUSD(algoUSDAddress);
        algoUSD.rebase(price);

        console.log("Rebase successful with price:", price);

        vm.stopBroadcast();
    }
}