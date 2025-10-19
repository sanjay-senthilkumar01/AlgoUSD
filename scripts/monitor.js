const { ethers } = require("ethers");
const fetch = require("node-fetch");

const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
const contractAddress = process.env.CONTRACT_ADDRESS;
const webhookUrl = process.env.WEBHOOK_URL;

const algoUSDABI = [
  "event RebaseFailed(string reason)",
  "event TargetPriceUpdated(uint256 newTargetPrice)",
  "event MintExecuted(address to, uint256 amount)",
  "event BurnExecuted(address from, uint256 amount)"
];

const algoUSDContract = new ethers.Contract(contractAddress, algoUSDABI, provider);

console.log("Listening for AlgoUSD contract events...");

// Send alert to webhook
async function sendWebhook(message) {
  try {
    const response = await fetch(webhookUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text: message }),
    });

    if (!response.ok) {
      console.error("Failed to send webhook notification.");
    }
  } catch (error) {
    console.error("Error sending webhook:", error);
  }
}

// Event Listeners
algoUSDContract.on("RebaseFailed", (reason) => {
  console.log("Rebase Failed:", reason);
  sendWebhook(`Rebase Failed: ${reason}`);
});

algoUSDContract.on("TargetPriceUpdated", (newTargetPrice) => {
  console.log("Target Price Updated to:", ethers.utils.formatEther(newTargetPrice));
  sendWebhook(`Target Price Updated to: ${ethers.utils.formatEther(newTargetPrice)} USD`);
});

algoUSDContract.on("MintExecuted", (to, amount) => {
  console.log(`Mint Executed: ${amount} tokens minted to ${to}`);
  sendWebhook(`Mint Executed: ${ethers.utils.formatEther(amount)} AUSD minted to ${to}`);
});

algoUSDContract.on("BurnExecuted", (from, amount) => {
  console.log(`Burn Executed: ${amount} tokens burned from ${from}`);
  sendWebhook(`Burn Executed: ${ethers.utils.formatEther(amount)} AUSD burned from ${from}`);
});

// Detect large transfers
algoUSDContract.on("Transfer", (from, to, amount) => {
  const threshold = ethers.utils.parseEther("100000"); // Set large transfer threshold
  if (amount.gte(threshold)) {
    console.log(`Large Transfer Detected: ${ethers.utils.formatEther(amount)} AUSD from ${from} to ${to}`);
    sendWebhook(`Large Transfer Alert: ${ethers.utils.formatEther(amount)} AUSD transferred from ${from} to ${to}`);
  }
});
