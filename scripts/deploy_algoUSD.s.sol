// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "contracts/AlgoUSD.sol";
import "@openzeppelin/contracts/access/TimelockController.sol";

/**
 * @title Script to deploy AlgoUSD contract with TimelockController
 */
contract DeployAlgoUSD is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Replace with the actual Chainlink Price Feed address
        address priceFeedAddress = vm.envAddress("PRICE_FEED_ADDRESS");

        // Replace with the initial owner address
        address initialOwner = vm.envAddress("INITIAL_OWNER_ADDRESS");

        // Multisig and timelock configuration
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

        // Deploy AlgoUSD contract with price feed address and timelock settings
        AlgoUSD algoUSD = new AlgoUSD(priceFeedAddress, timelockAdmin);

        console.log("AlgoUSD deployed to:", address(algoUSD));
        console.log("TimelockController deployed to:", address(timelockController));

        vm.stopBroadcast();
    }
}