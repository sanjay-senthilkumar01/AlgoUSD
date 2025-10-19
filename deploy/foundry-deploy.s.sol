// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "contracts/AlgoUSD.sol";
import "contracts/OracleAggregator.sol";
import "contracts/CircuitBreaker.sol";
import "@openzeppelin/contracts/access/TimelockController.sol";

/**
 * @title Deploy AlgoUSD using Foundry
 */
contract DeployFoundry is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Environment Variables: Testnet/Mainnet Deployment Inputs
        address priceFeedAddress1 = vm.envAddress("PRICE_FEED_ADDRESS_1");
        address priceFeedAddress2 = vm.envAddress("PRICE_FEED_ADDRESS_2");
        address timelockAdmin = vm.envAddress("TIMELOCK_ADMIN");
        address multisigAdmin = vm.envAddress("MULTISIG_ADMIN");

        // Multisig addresses for the TimelockController
        address[] memory proposers = new address[](3);
        proposers[0] = vm.envAddress("MULTISIG_SIGNER_1");
        proposers[1] = vm.envAddress("MULTISIG_SIGNER_2");
        proposers[2] = vm.envAddress("MULTISIG_SIGNER_3");

        address[] memory executors = new address[](2);
        executors[0] = vm.envAddress("MULTISIG_SIGNER_4");
        executors[1] = vm.envAddress("MULTISIG_SIGNER_5");

        // Deploy TimelockController
        TimelockController timelockController = new TimelockController(
            2 days, // Minimum delay
            proposers,
            executors
        );

        // Deploy CircuitBreaker
        CircuitBreaker circuitBreaker = new CircuitBreaker(multisigAdmin, 10); // Max 10% rebase cap

        // Deploy OracleAggregator
        OracleAggregator oracleAggregator = new OracleAggregator(3600, timelockAdmin); // Staleness threshold: 1 hour
        oracleAggregator.addPriceFeed(priceFeedAddress1, false); // Primary Oracle
        oracleAggregator.addPriceFeed(priceFeedAddress2, true);  // Fallback Oracle

        // Deploy AlgoUSD contract
        AlgoUSD algoUSD = new AlgoUSD(
            address(oracleAggregator),
            address(circuitBreaker),
            timelockAdmin
        );

        console.log("AlgoUSD Address:", address(algoUSD));
        console.log("OracleAggregator Address:", address(oracleAggregator));
        console.log("CircuitBreaker Address:", address(circuitBreaker));
        console.log("TimelockController Address:", address(timelockController));

        vm.stopBroadcast();
    }
}