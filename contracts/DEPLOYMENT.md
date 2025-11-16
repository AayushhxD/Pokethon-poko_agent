# Smart Contract Deployment Guide

## Prerequisites

- [Remix IDE](https://remix.ethereum.org) OR
- [Hardhat](https://hardhat.org) OR
- [thirdweb CLI](https://portal.thirdweb.com/cli)

## Option 1: Deploy with Remix (Easiest)

### Step 1: Open Remix
Go to https://remix.ethereum.org

### Step 2: Create Contract
1. Create new file: `PokeAgent.sol`
2. Paste the contract code
3. Compile with Solidity 0.8.20+

### Step 3: Deploy to Base Sepolia
1. Install MetaMask
2. Add Base Sepolia network:
   - Network Name: Base Sepolia
   - RPC URL: https://sepolia.base.org
   - Chain ID: 84532
   - Currency: ETH
   - Block Explorer: https://sepolia.basescan.org

3. Get testnet ETH:
   - Faucet: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
   - Bridge from Goerli: https://bridge.base.org/

4. In Remix:
   - Environment: "Injected Provider - MetaMask"
   - Select your account
   - Click "Deploy"
   - Confirm in MetaMask

5. Copy contract address!

### Step 4: Verify Contract (Optional)
1. Go to https://sepolia.basescan.org
2. Find your contract
3. Click "Verify and Publish"
4. Select Solidity version and paste code

## Option 2: Deploy with Hardhat

### Setup
```bash
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npx hardhat init
```

### Install Dependencies
```bash
npm install @openzeppelin/contracts
```

### Configure hardhat.config.js
```javascript
require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    baseSepolia: {
      url: "https://sepolia.base.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 84532,
    },
    base: {
      url: "https://mainnet.base.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 8453,
    },
  },
  etherscan: {
    apiKey: {
      baseSepolia: process.env.BASESCAN_API_KEY,
    },
  },
};
```

### Create Deploy Script
```javascript
// scripts/deploy.js
async function main() {
  const PokeAgent = await ethers.getContractFactory("PokeAgent");
  const pokeAgent = await PokeAgent.deploy();
  await pokeAgent.deployed();
  
  console.log("PokeAgent deployed to:", pokeAgent.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

### Deploy
```bash
npx hardhat run scripts/deploy.js --network baseSepolia
```

## Option 3: Deploy with thirdweb

```bash
npx thirdweb deploy
```

Select Base Sepolia network and follow prompts.

## After Deployment

### Update Flutter App
Edit `lib/utils/constants.dart`:
```dart
static const String pokeAgentContractAddress = '0xYOUR_CONTRACT_ADDRESS';
```

### Test Contract
```javascript
// In Remix or Hardhat console
const contract = await ethers.getContractAt("PokeAgent", "0xYOUR_ADDRESS");

// Mint agent
await contract.mint(
  "0xYourWalletAddress",
  "Pikachu",
  "Electric",
  "ipfs://QmExample...",
  { value: ethers.utils.parseEther("0.001") }
);

// Get agent
const agent = await contract.getAgent(0);
console.log(agent);
```

## Network Information

### Base Sepolia Testnet
- Chain ID: 84532
- RPC: https://sepolia.base.org
- Explorer: https://sepolia.basescan.org
- Faucet: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet

### Base Mainnet
- Chain ID: 8453
- RPC: https://mainnet.base.org
- Explorer: https://basescan.org

## Contract Functions

### Public Functions
- `mint(to, name, agentType, tokenURI)` - Mint new agent (0.001 ETH)
- `updateAgent(tokenId, newXP, newStage)` - Update agent stats
- `getAgent(tokenId)` - Get agent metadata
- `tokensOfOwner(owner)` - Get all token IDs for owner
- `totalSupply()` - Get total minted

### Owner Functions
- `setMintFee(newFee)` - Update mint price
- `withdraw()` - Withdraw contract balance

## Gas Estimates
- Deploy: ~2-3M gas
- Mint: ~150k gas
- Update: ~50k gas

## Security Notes
- Contract uses OpenZeppelin standards
- Owner controls mint fee
- Max supply: 10,000
- Each agent tracks XP and evolution stage
- Agents can be updated by owners only

## Troubleshooting

### "Insufficient funds" error
- Get testnet ETH from faucet
- Check you're on correct network

### "Contract not deployed" error
- Verify contract address
- Check network in MetaMask

### Verification failed
- Ensure Solidity version matches
- Include constructor arguments if any
- Flatten contract if using imports

---

**Ready to deploy? Let's go! 🚀**
