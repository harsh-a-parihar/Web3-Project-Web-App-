const hre = require("hardhat");

async function main() {
  // Get the contract factory
  const ChatApp = await hre.ethers.getContractFactory("ChatApp");

  // Deploy the contract
  const chatApp = await ChatApp.deploy();

  // Wait for deployment
  await chatApp.waitForDeployment();

  // Correct way to fetch address
  console.log("ChatApp deployed to:", await chatApp.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});