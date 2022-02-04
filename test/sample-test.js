const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFT", function () {
  it("Should mint a NFT and return its item ID ", async function () {
    const NFT = await hre.ethers.getContractFactory("IdeaUsher");
    const nft = await NFT.deploy();
    const [owner, addr1] = await ethers.getSigners();

    await nft.deployed();

    //Test to check the owner of the contract   
    expect(await nft.owner()).to.equal(owner.address);
  

    //Test to check the mintNFT function
    const tokenURI = "https://gateway.pinata.cloud/ipfs/QmY6FPqCf1r6kqPL83Fw25ayyCugiH95qb8KFNT4PEH9qY";
    const tx = await nft.mintNFT(addr1.address, tokenURI);
    const receipt = await tx.wait();
    const itemId = receipt.events.NFTMinted.returnValues.id;

    expect(itemId).to.equal(1);


  });
});
