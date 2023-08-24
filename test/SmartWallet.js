const { expect } = require("chai");
const hre = require("hardhat");
//const { boolean } = require("hardhat/internal/core/params/argumentTypes");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
describe("SmartWallet", function () {
  async function deployWalletAndSendMoney() {
    const SmartWallet = await hre.ethers.getContractFactory("SmartWallet");
    const smartWalletInstance = await SmartWallet.deploy();

    const [owner] = await hre.ethers.getSigners();
    const transactionHash = await owner.sendTransaction({
      to: smartWalletInstance.address,
      value: ethers.utils.parseEther("10"),
      gasLimit: 23000, // Sends exactly 1 ether
    });
    transactionHash.wait(2);
    return { smartWalletInstance };
  }
  it("should able to give access ", async () => {
    const { smartWalletInstance } = await loadFixture(deployWalletAndSendMoney);

    const [owner, guardian1, guardian2] = await hre.ethers.getSigners();

    //giving access to guardian1 of 1
    const t1 = await smartWalletInstance.allowAccessAndMoney(
      1,
      guardian1.address
    );

    //console.log(t1);
    // address addr;
    // uint amount;
    // bool access;

    const t2 = await smartWalletInstance.getGuardianWithAmount(
      guardian1.address
    );
    //console.log(t2);

    expect(t2).to.deep.include(guardian1.address);

    expect(t2).to.deep.include(true);
  });
  it("should be able to deny access to allowed guardian", async () => {
    const { smartWalletInstance } = await loadFixture(deployWalletAndSendMoney);

    const [owner, guardian1, guardian2] = await hre.ethers.getSigners();
    //giving access to guardian1 and guardian2
    const t1 = await smartWalletInstance.allowAccessAndMoney(
      hre.ethers.utils.parseEther("1"),
      guardian1.address
    );
    const t2 = await smartWalletInstance.allowAccessAndMoney(
      hre.ethers.utils.parseEther("2"),
      guardian2.address
    );
    //denying access to guardian1
    const t3 = await smartWalletInstance.denyAccess(guardian1.address);

    await expect(smartWalletInstance.getGuardianWithAmount(guardian1.address))
      .to.be.reverted;
  });
});
