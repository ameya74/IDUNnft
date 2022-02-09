require("dotenv").config();

const API_URL = process.env.API_URL;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(API_URL);

//Calling the ERC20 contract
const contractERC20 = require('../artifacts/contracts/ERC20.sol/IdeaUsherToken.json');
const ContractAddressERC20 = "0xaEE18812Ba76e83A66FeDA7701fC560E541D448e";
const ERC20Contract = new web3.eth.Contract(contractERC20.abi, ContractAddressERC20);

async function mintERC20() {
  // To get the Latest Nonce
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest");
  console.log("Nonce: " + nonce);
  //The amount to be minted
  const amount = web3.utils.toWei("100", "ether");
  //The Transaction made
  const TX = {
    from: PUBLIC_KEY,
    to: ContractAddressERC20,
    nonce: nonce,
    gas: 900000,
    maxPriorityGasPrice: 1999999987,
    data: ERC20Contract.methods.mint(PUBLIC_KEY, amount).encodeABI(),
  };
  const SignPromise = web3.eth.accounts.signTransaction(TX, PRIVATE_KEY);
  SignPromise.then((signedTX) => {
    web3.eth.sendSignedTransaction(signedTX.rawTransaction, (err, hash) => {
      if (!err) {
        console.log(
          "The hash of your Transaction is:",
          hash,
          "\nCheck Alchemy's Mempool to view the status of your transaction!"
        );
      } else {
        console.log("Something went wrong:", err);
      }
    });
  }).catch((err) => {
    console.log("Promise Failed:", err);
  });
}

mintERC20();
