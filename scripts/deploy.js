//const hre = require("hardhat");
(async () => {
  try {
    const SmartWallet = await hre.ethers.getContractFactory("SmartWallet");
    const smartWalletInstance = await SmartWallet.deploy();
    await smartWalletInstance.deployed();
    console.log(`deployed contract at ${smartWalletInstance.address}`);
  } catch (err) {
    console.error(err);
    process.exitCode = 1;
  }
})();
