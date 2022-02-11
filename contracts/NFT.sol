// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "./ERC721A.sol";

contract IdeaUsher is ERC721A, ReentrancyGuard, Ownable, Pausable  {

    using ECDSA for bytes32;
    using Strings for uint256;

    //Used to validate authorised mint Addresses
    address private signerAddress = 0x65257d293ad2172926e0F8bD1cD4E3A45cB9C7b8;

    //Public Vars
    string public baseTokenURI;
    uint256 public price = 0.125 ether;

    //Immutable Vars
    uint256 public immutable maxSupply;

    constructor(string memory name, string memory symbol, string memory baseTokenURI_, uint256 maxSupply_) ERC721A(name, symbol)  
    {   require(maxSupply_ > 0, "Max Supply must be greater than 0");
        baseTokenURI = baseTokenURI_;
        maxSupply = maxSupply_;        
    }
 
    
    mapping(address => uint256) public totalMintsPerAddress;
    mapping(address => bool) whitelistAddresses;

    bool public isSaleActive = false;

    function tokenURI (uint256 tokenId) public view  virtual override  returns (string memory) {
        require(_exists(tokenId), "Token does not exist i.e URI query for nonexistent token");
        return string(abi.encodePacked(_baseURI(), tokenId.toString(), ".json"));
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }
    /**
     * To be updated by contract owner to allow updating the mint price
     */

    function setSalePrice(uint256 _newMintPrice) public onlyOwner {
        require(price != _newMintPrice, "Price is already set to this value");
        price = _newMintPrice;
    }
    /**
    *   To be updated by contract owner to change the sale status
     */
    function setSaleStatus(bool _newSaleStatus) public onlyOwner {
        require(isSaleActive != _newSaleStatus, "Sale status is already set to this value");
        isSaleActive = _newSaleStatus;
    }
    function setSignerAddress(address _signerAddress) external onlyOwner {
        require(_signerAddress != address(0), "Signer address cannot be 0x0");
        signerAddress = _signerAddress;
    }

    /**
    Returns all token ids owned by the address
     */
    function getTokensByAddress(address owner) public view returns (uint256[] memory) {
        require(owner != address(0), "Owner cannot be the null address");
        uint256 totalTokensOwned = balanceOf(owner);
        uint256[] memory allTokenIds = new uint256[](totalTokensOwned);
        for (uint256 i = 0; i < totalTokensOwned; i++) {
            allTokenIds[i] = (tokenOfOwnerByIndex(owner, i));
        }
        return allTokenIds;
    }
    /**
    Update the Base URI
    */
    function setBaseTokenURI(string calldata _newBaseURI) external onlyOwner {
        baseTokenURI = _newBaseURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
    When the contract is Paused all transfers are prevented in case of emergency
    */
    function _beforeTokenTransfers( address from, address to, uint256 tokenId, uint256 quantity)internal whenNotPaused override(ERC721A){
        super._beforeTokenTransfers(from, to, tokenId, quantity);        
    }

    /**
    Function to verify the Address Signer
    */

    function verifyAddressSigner( bytes32 messageHash, bytes memory signature) private view returns (bool) {
        return signerAddress == messageHash.toEthSignedMessageHash().recover(signature);
    }

    /**
    Function to hash the message
    */
    function hashMessage(address sender ,  uint256 maximumAllowedMints) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(sender, maximumAllowedMints));
    }
    
    /**
     * @notice Allow for minting of tokens up to the maximum allowed for a given address.
     * The address of the sender and the number of mints allowed are hashed and signed
     * with the server's private key and verified here to prove whitelisting status.
     */

    function mintNFT (bytes32 messageHash, bytes calldata signature, uint256 mintNumber,uint256 maximumAllowedMints ) external payable virtual nonReentrant{
        require(isSaleActive, "Sale is not active");
        require(verifyAddressSigner(messageHash, signature), "Signature is not valid");
        require(hashMessage(msg.sender, maximumAllowedMints) == messageHash, "MESSAGE_INVALID");
        require(mintNumber > 0, "Mint number must be greater than 0");
        require(maximumAllowedMints > 0, "Maximum allowed mints must be greater than 0");
        require(totalMintsPerAddress[msg.sender] + mintNumber <= maximumAllowedMints, "Maximum allowed mints exceeded");
        require(msg.value >= ((price * mintNumber) - 0.0001 ether) && msg.value <= ((price * mintNumber) + 0.0001 ether), "INVALID_PRICE");

        uint256 currentSupply = totalSupply();

        require(currentSupply + mintNumber <= maxSupply, "MAX_SUPPLY_EXCEEDED");
        
        totalMintsPerAddress[msg.sender] += mintNumber;
        _safeMint(msg.sender, mintNumber);

        if(currentSupply + mintNumber >= maxSupply) {
            isSaleActive = false;
        }
    }

}
