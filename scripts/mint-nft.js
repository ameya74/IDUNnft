require("dotenv").config();

const API_URL = process.env.API_URL;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const { createAlchemyWeb3 } = require('@alch/alchemy-web3')
const web3 = createAlchemyWeb3(API_URL);

const contract = require('../artifacts/contracts/NFT.sol/IdeaUsher.json');
const ContractAddress = "0xeb9DD5A4BFb209f8B15b16D6d65E25143e91c18d";
const NFTContract = new web3.eth.Contract(contract.abi, ContractAddress);

async function mintNFT(tokenURI) {
    const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, 'latest') // To get the Latest Nonce

    //The Transaction made

    const TX = {
        from: PUBLIC_KEY,
        nonce: nonce,
        gas: 500000,
        data: NFTContract.methods.mintNFT(PUBLIC_KEY, tokenURI).encodeABI()
    };

    const SignPromise = web3.eth.accounts.signTransaction(TX, PRIVATE_KEY)
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
        })
    }).catch((err) => {
        console.log("Promise Failed:", err);
    })
}

mintNFT(
  "https://gateway.pinata.cloud/ipfs/QmY6FPqCf1r6kqPL83Fw25ayyCugiH95qb8KFNT4PEH9qY"
);