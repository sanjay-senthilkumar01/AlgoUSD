// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "contracts/AlgoUSD.sol";
import "@openzeppelin/contracts/access/TimelockController.sol";
import "contracts/OracleAggregator.sol";
import "contracts/CircuitBreaker.sol";

/**
 * @title Script to deploy AlgoUSD contract with TimelockController and OracleAggregator
 */
contract DeployAlgoUSDWithAggregator is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Chainlink Price Feed and Admin Configuration
        address priceFeedAddress1 = vm.envAddress("PRICE_FEED_ADDRESS_1");
        address priceFeedAddress2 = vm.envAddress("PRICE_FEED_ADDRESS_2");
        address adminAddress = vm.envAddress("ADMIN_ADDRESS");

        // Multisig addresses for the TimelockController
        address[] memory proposers = new address[](3);
        proposers[0] = vm.envAddress("MULTISIG_SIGNER_1");
        proposers[1] = vm.envAddress("MULTISIG_SIGNER_2");
        proposers[2] = vm.envAddress("MULTISIG_SIGNER_3");

        address[] memory executors = new address[](2);
        executors[0] = vm.envAddress("MULTISIG_SIGNER_4");
        executors[1] = vm.envAddress("MULTISIG_SIGNER_5");

        address timelockAdmin = vm.envAddress("TIMELOCK_ADMIN");

        // Deploy TimelockController
        TimelockController timelockController = new TimelockController(
            2 days,  // Minimum delay
            proposers,
            executors
        );

        // Deploy CircuitBreaker
        CircuitBreaker circuitBreaker = new CircuitBreaker(timelockAdmin, 10); // Max 10% rebase cap

        // Deploy OracleAggregator
        OracleAggregator oracleAggregator = new OracleAggregator(
            3600, // Staleness threshold: 1 hour
            adminAddress
        );

        oracleAggregator.addPriceFeed(priceFeedAddress1, false); // Primary feed
        oracleAggregator.addPriceFeed(priceFeedAddress2, true);  // Fallback feed

        // Deploy AlgoUSD contract with OracleAggregator and CircuitBreaker integration
        AlgoUSD algoUSD = new AlgoUSD(address(oracleAggregator), address(circuitBreaker), timelockAdmin);

        console.log("AlgoUSD deployed to:", address(algoUSD));
        console.log("OracleAggregator deployed to:", address(oracleAggregator));
        console.log("CircuitBreaker deployed to:", address(circuitBreaker));
        console.log("TimelockController deployed to:", address(timelockController));

        vm.stopBroadcast();
    }
}