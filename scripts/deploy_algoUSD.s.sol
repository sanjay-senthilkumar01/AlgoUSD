// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "contracts/AlgoUSD.sol";

/**
 * @title Script to deploy AlgoUSD contract
 */
contract DeployAlgoUSD is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Replace with the actual Chainlink Price Feed address
        address priceFeedAddress = vm.envAddress("PRICE_FEED_ADDRESS");

        // Deploy AlgoUSD contract
        AlgoUSD algoUSD = new AlgoUSD(priceFeedAddress);

        console.log("AlgoUSD deployed to:", address(algoUSD));

        vm.stopBroadcast();
    }
}