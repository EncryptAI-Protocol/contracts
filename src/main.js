const { ethers } = require("ethers");

// Replace with your network provider URL (e.g., Infura, Alchemy, or a local node)
const provider = new ethers.providers.JsonRpcProvider("https://rpc.testnet.moonbeam.network");

// Replace with the private key of the account you'll use to send the transactions
const privateKey = "YOUR_PRIVATE_KEY";
const wallet = new ethers.Wallet(privateKey, provider);

// Replace with the deployed addresses of your contracts
const consumerAddress = "CONSUMER_CONTRACT_ADDRESS";
const batchAddress = "0x0000000000000000000000000000000000000808";

// ABI for the Batch contract
const batchAbi = [
    "function batchAll(address[] memory to, uint256[] memory value, bytes[] memory callData, uint64[] memory gasLimit) external"
];

// ABI for the Consumer contract
const consumerAbi = [
    "function payForModelUsage() external payable",
    "function grantAccessToDataNFT(address user) external",
    "function grantAccessToModelNFT(address user) external"
];

async function main() {
    // Create instances of the contracts
    const batchContract = new ethers.Contract(batchAddress, batchAbi, wallet);
    const consumerContract = new ethers.Contract(consumerAddress, consumerAbi, wallet);

    // Define the user address for grant access functions
    const userAddress = "USER_ADDRESS";

    // Encode the function calls
    const payForModelUsageData = consumerContract.interface.encodeFunctionData("payForModelUsage");
    const grantAccessToDataNFTData = consumerContract.interface.encodeFunctionData("grantAccessToDataNFT", [userAddress]);
    const grantAccessToModelNFTData = consumerContract.interface.encodeFunctionData("grantAccessToModelNFT", [userAddress]);

    // Define the parameters for the batch call
    const to = [consumerAddress, consumerAddress, consumerAddress];
    const value = [ethers.utils.parseEther("0.1"), 0, 0]; // Sending 0.1 ETH for payForModelUsage, 0 for others
    const callData = [payForModelUsageData, grantAccessToDataNFTData, grantAccessToModelNFTData];
    const gasLimit = []; // Use 0 to forward all the remaining gas

    // Execute the batch call
    const tx = await batchContract.batchAll(to, value, callData, gasLimit, {
        value: ethers.utils.parseEther("0.1") // Total ETH sent in the transaction
    });

    console.log(`Batch transaction sent: ${tx.hash}`);
    const receipt = await tx.wait();
    console.log(`Batch transaction mined: ${receipt.transactionHash}`);
}

main().catch(error => {
    console.error("Error executing batch transaction:", error);
});
