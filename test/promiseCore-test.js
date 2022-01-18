const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  let promiseCore, token1, token2;

  before("deploy contracts", async function () {
    const ShareCalculator = await hre.ethers.getContractFactory("ShareCalculator");
    const shareCalculator = await ShareCalculator.deploy();

    await shareCalculator.deployed();

    const PromiseCore = await hre.ethers.getContractFactory("PromiseCore", {
      libraries: {
        ShareCalculator: shareCalculator.address,
      },
    });

    const CreatorNFT = await hre.ethers.getContractFactory("CreatorNFT");
    const JoinerNFT = await hre.ethers.getContractFactory("JoinerNFT");

    promiseCore = await PromiseCore.deploy("0x000000000000000000000000000000000000dEaD");

    await promiseCore.deployed();

    console.log("PromiseCore deployed to:", promiseCore.address);

    const creatorNFT = await CreatorNFT.deploy();
    const joinerNFT = await JoinerNFT.deploy();

    await creatorNFT.deployed();
    await joinerNFT.deployed();

    console.log("CreatorNFT deployed to:", creatorNFT.address);
    console.log("JoinerNFT deployed to:", joinerNFT.address);

    await creatorNFT.transferOwnership(promiseCore.address);
    await joinerNFT.transferOwnership(promiseCore.address);

    console.log("Ownership of NFTs transferred to promise");

    await promiseCore.addNFTs(creatorNFT.address, joinerNFT.address);

    console.log("NFT addresses added to promise");

    const PromiseToken = await hre.ethers.getContractFactory("PromiseToken");

    token1 = await PromiseToken.deploy();
    token2 = await PromiseToken.deploy();

    await token1.deployed();
    await token2.deployed();

    console.log("Token1 deployed to:", token1.address);
    console.log("Token2 deployed to:", token2.address);
  });
  it("Open Promise", async () => {
    const [owner] = await ethers.getSigners();

    await token1.approve(promiseCore.address, "100000");

    await promiseCore.createPromise(owner.address, token1.address, "100", token2.address, "40000", "12341234123412341234");
  });
  it("join Promise", async () => {
    const [owner] = await ethers.getSigners();

    await token2.approve(promiseCore.address, "100000");

    await promiseCore.joinPromise(1, "0x000000000000000000000000000000000000dEaD", "4");
  });
});
