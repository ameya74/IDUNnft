// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC20.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _nftIdCounter;
    Counters.Counter private _nftItemsSold;

    address payable owner;
    

    constructor() {
        owner = payable(msg.sender);
    }

    struct NFTItem {
        uint256 Itemid;
        address nftContract;
        uint256 nftTokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool isSold;
    }

    mapping(uint256 => NFTItem) private _nftItems;

    //TODO: Add the event for the NFT item created
    event NFTItemCreated(uint256 indexed Itemid, address indexed nftContract, uint256 indexed nftTokenId, address seller,address owner ,uint256 price, bool isSold);

    uint256 listingPrice = 0.01 ether;

    /// @notice returns the Listing Price
    /// @dev Not neccessary and can be removed
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }
    
    /// @notice Place an Item for Sale
    function placeItemForSale(address nftContract, uint256 nftTokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be greater than 0");
        require(msg.value >= listingPrice, "Amount must be greater than or equal to the Listing Price");

        _nftIdCounter.increment();
        uint256 itemId = _nftIdCounter.current();

        _nftItems[itemId] = NFTItem(
            itemId,
            nftContract,
            nftTokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), nftTokenId);

        //emit an event for the item created
        emit NFTItemCreated(itemId, nftContract, nftTokenId, msg.sender, address(0), price, false);
        
    }
    /// @notice Buy an Item
    function createMarketSale(uint itemId, address nftContract)  public payable nonReentrant {
        uint256 price = _nftItems[itemId].price;
        uint nftTokenId = _nftItems[itemId].nftTokenId;

        require(msg.value >= price, "Amount must be greater than or equal to the price");

        _nftItems[itemId].seller.transfer(msg.value);

        IERC721(nftContract).transferFrom(address(this), msg.sender, nftTokenId);

        _nftItems[itemId].owner = payable(msg.sender);
        _nftItems[itemId].isSold = true;

        _nftItemsSold.increment();        
    }
    /// @notice Returns all Unsold Items
    function getUnsoldItems() public view returns (NFTItem[] memory) {
        uint itemCount = _nftIdCounter.current();
        uint unsoldItemCount = _nftIdCounter.current() - _nftItemsSold.current();
        uint currentIndex = 0;

        NFTItem[] memory unsoldItems = new NFTItem[](unsoldItemCount);
        
        for (uint256 index = 0; index < itemCount; index++) {
            if (_nftItems[index+1].owner == msg.sender) {        
                uint CurrentID = index +1;
                NFTItem memory Currentitem = _nftItems[CurrentID];
                unsoldItems[currentIndex] = Currentitem;
                currentIndex++;
            }
        }
        return unsoldItems;
    }

    /// @notice Returns only items that a user has bought
    function fetchUserNFT () public view returns(NFTItem[] memory) {
        uint TotalItemCount = _nftIdCounter.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint256 index = 0; index < TotalItemCount ; index++) {
            if (_nftItems[index+1].owner == msg.sender) {
                itemCount++;
            }
        }
        NFTItem[] memory userNFT = new NFTItem[](itemCount);

        for (uint256 index = 0; index < TotalItemCount; index++) {
            if (_nftItems[index+1].owner == msg.sender) {
                uint CurrentID = index +1;
                NFTItem memory Currentitem = _nftItems[CurrentID];
                userNFT[currentIndex] = Currentitem;
                currentIndex++;
            }
        }
        return userNFT;    
    }
    ///@notice Returns all items that are user has created
    function getUserItems() public view returns(NFTItem[] memory) {
        uint TotalItemCount = _nftIdCounter.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint256 index = 0; index < TotalItemCount ; index++) {
            if (_nftItems[index+1].seller == msg.sender) {
                itemCount++;
            }
        }
        NFTItem[] memory userNFT = new NFTItem[](itemCount);

        for (uint256 index = 0; index < TotalItemCount; index++) {
            if (_nftItems[index+1].seller == msg.sender) {
                uint CurrentID = index +1;
                NFTItem memory Currentitem = _nftItems[CurrentID];
                userNFT[currentIndex] = Currentitem;
                currentIndex++;
            }
        }
        return userNFT;    
    }

}