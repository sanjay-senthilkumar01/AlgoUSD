// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "contracts/AlgoUSD.sol";

/**
 * @title Script to burn AlgoUSD tokens
 */
contract BurnAlgoUSD is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Replace with the actual deployed AlgoUSD contract address
        address algoUSDAddress = vm.envAddress("AUSD_CONTRACT_ADDRESS");
        address from = vm.envAddress("BURN_ADDRESS");
        uint256 burnAmount = vm.envUint("BURN_AMOUNT");

        AlgoUSD algoUSD = AlgoUSD(algoUSDAddress);
        algoUSD.burn(from, burnAmount);

        console.log("Burned", burnAmount, "AUSD tokens from", from);

        vm.stopBroadcast();
    }
}