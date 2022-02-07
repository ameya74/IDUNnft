//Deploy the NFT MArket contract
const hre = require("hardhat");

async function main() {
  // We get the contract to deploy
  const NFTMarket = await hre.ethers.getContractFactory("NFTMarket");
  const nftmarket = await NFTMarket.deploy();

  await nftmarket.deployed();

  console.log("NFT deployed to:", nftmarket.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
