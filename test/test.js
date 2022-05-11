const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

describe("Velamis Token Test", function () {
  it("Should return the new Velamis once it's changed", async function () {
    const [owner, ManageWallet, PauseWallet] = await ethers.getSigners();
    const _marketCap = BigNumber.from("300000000000000000000000000");
    console.log("MarketCap: ", _marketCap);
    console.log("ManageWallet address: ", ManageWallet.address);
    console.log("PauseWallet address: ", PauseWallet.address);

    const Velamis = await ethers.getContractFactory("Velamis");
    const velamisToken = await Velamis.deploy();
    await velamisToken.deployed();

    console.log("Deployed Velamis Token address: ", velamisToken.address);
    expect(await velamisToken.name()).to.equal("VELAMIS");
    expect(await velamisToken.symbol()).to.equal("VEL");
    expect(await velamisToken.status()).to.equal(true);

    //const ManageWallet = "0x6742e82826f03F69B46D86FF2Afaf870F9A188c6";
    const PrivSaleWallet = "0x2f609c920c78535bF3aE62B92ffb131Cb37b03EB";
    const PubSaleWallet = "0xd0BDc14f6457511655E2290c56FdAd5a3F96Ddea";
    const AdvisoryWallet = "0x1fa257b5aA21e21bD6fa0f421638661b8A422902";
    const TeamWallet = "0x7De8E2b7f921Ba243454B30406076a89FDf7c343";
    const EcoGrowthWallet = "0x5b58E5DF395F87Ce0cd2A677b9a48Cbb7cB3a843";
    const CompanyWallet = "0x333431Cdae737Cd1BF6ad26C22e443700710d819";
    const TreasuryWallet = "0xA9ED9C85A7Cc10ED3Cb439934a25D737C6b8d006";
    const StakingRewardWallet = "0x44a7CC9762C267180e0E09d56a84D70629258e29";
    //const PauseWallet = "0x13200C0FAC543e5A7f85791e65Bea038fE6eE25d";

    expect(await velamisToken.balanceOf(ManageWallet.address)).to.equal(0);
    expect(await velamisToken.balanceOf(PrivSaleWallet)).to.equal(0);

    await expect(
      velamisToken.issueTokens()
    ).to.be.revertedWith("VELAMIS: caller isn't manager of the contract");

    const issueTokensTx = await velamisToken.connect(ManageWallet).issueTokens();
    await issueTokensTx.wait();
    expect(await velamisToken.balanceOf(ManageWallet.address)).to.equal(_marketCap.mul(2222).div(10000));

    const distributeTokensTx1 = await velamisToken.connect(ManageWallet).distributeTokens(0);
    await distributeTokensTx1.wait();
    expect(await velamisToken.balanceOf(PrivSaleWallet)).to.equal(_marketCap.mul(5).div(100));

    const distributeTokensTx2 = await velamisToken.connect(ManageWallet).distributeTokens(1);
    await distributeTokensTx2.wait();
    expect(await velamisToken.balanceOf(PubSaleWallet)).to.equal(_marketCap.mul(10).div(100));

    const prevFund = await velamisToken.balanceOf(ManageWallet.address);
    const commissionAmount =BigNumber.from(10000000000000);
    const burnTokensTx = await velamisToken.connect(ManageWallet).burnTokens(commissionAmount);
    await burnTokensTx.wait();
    expect(await velamisToken.balanceOf(ManageWallet.address)).to.equal(prevFund.sub(commissionAmount.div(10)));

    const stopTx = await velamisToken.connect(PauseWallet).pauseContract();
    await stopTx.wait();
    expect(await velamisToken.status()).to.equal(false);
  });
});
