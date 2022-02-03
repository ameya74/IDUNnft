const hre = require("hardhat");

async function main() {
  // We get the contract to deploy
  const NFT = await hre.ethers.getContractFactory("IdeaUsher");
  const nft = await NFT.deploy();

  await nft.deployed();

  console.log("NFT deployed to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
