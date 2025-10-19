require("dotenv").config();
const hre = require("hardhat");

async function deployAlgoUSD() {
  const { PRICE_FEED_ADDRESS_1, PRICE_FEED_ADDRESS_2, MULTISIG_ADMIN, TIMELOCK_ADMIN, MULTISIG_SIGNERS } = process.env;

  const proposers = MULTISIG_SIGNERS.split(",").slice(0, 3);
  const executors = MULTISIG_SIGNERS.split(",").slice(3, 5);

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Deploying TimelockController...");
  const TimelockController = await hre.ethers.getContractFactory("TimelockController");
  const timelockController = await TimelockController.deploy(2 * 86400, proposers, executors, TIMELOCK_ADMIN);
  console.log("TimelockController deployed to:", timelockController.address);

  console.log("Deploying CircuitBreaker...");
  const CircuitBreaker = await hre.ethers.getContractFactory("CircuitBreaker");
  const circuitBreaker = await CircuitBreaker.deploy(TIMELOCK_ADMIN, 10);
  console.log("CircuitBreaker deployed to:", circuitBreaker.address);

  console.log("Deploying OracleAggregator...");
  const OracleAggregator = await hre.ethers.getContractFactory("OracleAggregator");
  const oracleAggregator = await OracleAggregator.deploy(3600, TIMELOCK_ADMIN);
  await oracleAggregator.addPriceFeed(PRICE_FEED_ADDRESS_1, false);
  await oracleAggregator.addPriceFeed(PRICE_FEED_ADDRESS_2, true);
  console.log("OracleAggregator deployed to:", oracleAggregator.address);

  console.log("Deploying AlgoUSD...");
  const AlgoUSD = await hre.ethers.getContractFactory("AlgoUSD");
  const algoUSD = await AlgoUSD.deploy(
    oracleAggregator.address,
    circuitBreaker.address,
    TIMELOCK_ADMIN
  );
  console.log("AlgoUSD deployed to:", algoUSD.address);
}

deployAlgoUSD()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });