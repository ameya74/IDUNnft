const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFT", function () {
  it("Should mint a NFT and return its item ID ", async function () {
    const NFT = await hre.ethers.getContractFactory("IdeaUsher");
    const nft = await NFT.deploy();
    const [owner, addr1] = await ethers.getSigners();

    await nft.deployed();

    const ItemId = await nft.mintNFT(addr1, "https://www.mytokenlocation.com");


    expect(ItemId.to.equal("1"));

  });
});
