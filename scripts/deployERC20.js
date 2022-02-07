//Deploy the ERC20 contract
const hre = require("hardhat");

async function main() {
    const Token = await hre.ethers.getContractFactory("IdeaUsherToken");
    const token = await Token.deploy();

    await token.deployed();
    console.log("Token deployed to:", token.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});