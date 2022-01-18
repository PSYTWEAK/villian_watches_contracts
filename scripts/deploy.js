// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const [owner] = await ethers.getSigners();
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

  const promiseCore = await PromiseCore.deploy(owner.address);

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

  const token1 = await PromiseToken.deploy();
  const token2 = await PromiseToken.deploy();

  await token1.deployed();
  await token2.deployed();

  console.log("Token1 deployed to:", token1.address);
  console.log("Token2 deployed to:", token2.address);

  const Helper = await hre.ethers.getContractFactory("Helper");

  const helper = await Helper.deploy();

  await helper.deployed();

  console.log("Helper deployed to:", helper.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
