const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFT", function () {
  it("Should mint a NFT and return its item ID ", async function () {
    const NFT = await hre.ethers.getContractFactory("IdeaUsher");
    const nft = await NFT.deploy();

    const nftContractAddress = nft.address;
    
    const Token = await hre.ethers.getContractFactory("IdeaUsherToken");
    const token = await Token.deploy();

    const MARKET = await hre.ethers.getContractFactory("NFTMarket");
    const market = await MARKET.deploy();   

    await nft.deployed();
    await token.deployed();
    await market.deployed();
    
    const [owner, addr1] = await ethers.getSigners();
    console.log("owner:", owner.address);

    //Test to check the owner of the contract   
    expect(await nft.owner()).to.equal(owner.address);
    expect(await token.owner()).to.equal(owner.address);
    

    //Test to check the mintNFT function
    const tokenURI = "https://gateway.pinata.cloud/ipfs/QmY6FPqCf1r6kqPL83Fw25ayyCugiH95qb8KFNT4PEH9qY";
    const tx = await nft.mintNFT(owner.address, tokenURI);
    const receipt = await tx.wait();
    const itemId = receipt.events.NFTMinted.returnValues.id;

    expect(itemId).to.equal(1);

    //Test to mint the tokens
    const amount =  ethers.utils.parseUnits("1000", 18);  // 1000 tokens
    const tx2 = await token.mint(owner.address, amount);
    const balance = await token.balanceOf(owner.address);

    expect(balance).to.equal(amount);

    let ListingPrice = await market.getListingPrice();
    ListingPrice = ListingPrice.toString();

    const AuctionPrice = ethers.utils.parseUnits("1", 18);  // 1 token
    await market.placeItemforSale(nftContractAddress, 1, AuctionPrice, {value: ListingPrice});

    // Execute a sale to another User
    await market
      .connect(addr1)
      .createMarketSale(nftContractAddress, 1, { value: AuctionPrice });
    //Query for and return all unsold Items
    const unsoldItems = await market.getUnsoldItems();
    const unsoldItems = await unsoldItems.Promise.all(unsoldItems.map(async (item) => {
      const tokenUri = await nft.tokenURI(item.id);
      const Item = {
        price: item.price.toString(),
        tokenId: item.tokenId.toString(),
        seller: item.seller,
        owner: item.owner,
        tokenUri: tokenUri,
      }
      return Item;
    }));
    console.log("unsoldItems:", unsoldItems);
  });
});
