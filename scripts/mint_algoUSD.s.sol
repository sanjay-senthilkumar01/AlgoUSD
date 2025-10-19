// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "contracts/AlgoUSD.sol";

/**
 * @title Script to mint AlgoUSD tokens
 */
contract MintAlgoUSD is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Replace with the actual deployed AlgoUSD contract address
        address algoUSDAddress = vm.envAddress("AUSD_CONTRACT_ADDRESS");
        address recipient = vm.envAddress("RECIPIENT_ADDRESS");
        uint256 mintAmount = vm.envUint("MINT_AMOUNT");

        AlgoUSD algoUSD = AlgoUSD(algoUSDAddress);
        algoUSD.mint(recipient, mintAmount);

        console.log("Minted", mintAmount, "AUSD tokens to", recipient);

        vm.stopBroadcast();
    }
}