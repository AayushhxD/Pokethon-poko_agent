# PokéAgents - AI-Powered NFT Agents on Base Blockchain

<div align="center">
  
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Blockchain](https://img.shields.io/badge/Blockchain-Base-0052FF)
![AI](https://img.shields.io/badge/AI-OpenAI-412991)
![License](https://img.shields.io/badge/License-MIT-green)

**A revolutionary Flutter dApp where users mint, train, and battle AI-powered Pokémon-inspired agents as NFTs on the Base blockchain.**

</div>

---

## 🚀 Features

- **🎨 Mint Unique Agents**: Create AI-powered PokéAgents with unique types (Fire, Water, Electric, Psychic, Grass, Ice)
- **💬 AI Training**: Chat with your agents to increase XP using OpenAI/Claude APIs
- **⚔️ Battle Arena**: Fight other agents in AI-simulated battles
- **✨ Evolution System**: Evolve your agents through multiple stages with stat boosts
- **🔗 Base Blockchain**: Mint NFTs on Base (Ethereum L2)
- **💼 Wallet Integration**: Connect with MetaMask/WalletConnect
- **📱 Cross-Platform**: Works on Web, iOS, and Android

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Frontend                        │
│  (Beautiful UI, Animations, Cross-platform)                 │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────┴──────────┬──────────────┬────────────┐
        │                    │              │            │
┌───────▼────────┐  ┌────────▼──────┐  ┌───▼──────┐  ┌─▼────────┐
│  AI Backend    │  │  Base Chain   │  │   IPFS   │  │  Wallet  │
│  (OpenAI/      │  │  (ERC-721)    │  │ Storage  │  │ Connect  │
│   Claude)      │  │               │  │          │  │          │
└────────────────┘  └───────────────┘  └──────────┘  └──────────┘
```

---

## 📦 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.x |
| **State Management** | Provider |
| **Blockchain** | Base (Sepolia Testnet) |
| **Web3** | web3dart, WalletConnect |
| **AI** | OpenAI API / Claude |
| **Storage** | IPFS / NFT.storage |
| **Styling** | Google Fonts (Poppins), Custom Theme |
| **Animations** | animate_do, Lottie |

---

## 🛠️ Setup Instructions

### Prerequisites

- Flutter SDK (3.7.2+)
- Dart SDK
- Node.js (for backend)
- MetaMask or compatible wallet

### 1. Clone and Install Dependencies

```bash
cd poko_agent
flutter pub get
```

### 2. Configure Environment

Update `lib/utils/constants.dart` with your configuration:

```dart
// API Endpoints
static const String baseApiUrl = 'https://your-backend.vercel.app/api';

// Contract Address (after deployment)
static const String pokeAgentContractAddress = '0x...';

// IPFS/NFT.storage
static const String nftStorageApiKey = 'YOUR_API_KEY';
```

### 3. Run the App

```bash
# Web
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android
```

---

## 🎮 How to Play

### 1️⃣ Connect Wallet
- Tap "Connect Wallet" to link your MetaMask
- Switch to Base Sepolia Testnet

### 2️⃣ Mint Your First Agent
- Choose an agent type (Fire, Water, Electric, etc.)
- Enter a name
- Mint your NFT on Base blockchain

### 3️⃣ Train Your Agent
- Chat with your agent to build a bond
- Each interaction earns +5 XP
- Agents respond with unique AI personalities

### 4️⃣ Battle in the Arena
- Select an opponent
- Watch AI-simulated battles unfold
- Win battles to earn +20 XP

### 5️⃣ Evolve Your Agent
- Reach XP thresholds:
  - Stage 2: 100 XP
  - Stage 3: 300 XP
  - Stage 4: 600 XP
- Evolved agents get massive stat boosts!

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── pokeagent.dart          # Agent data model
├── screens/
│   ├── splash_screen.dart      # Animated intro
│   ├── home_screen.dart        # Agent collection
│   ├── mint_screen.dart        # Mint new agents
│   ├── train_screen.dart       # AI chat training
│   ├── battle_screen.dart      # Battle arena
│   └── evolution_screen.dart   # Evolution interface
├── services/
│   ├── ai_service.dart         # OpenAI/Claude integration
│   ├── blockchain_service.dart # Base blockchain calls
│   ├── ipfs_service.dart       # NFT metadata storage
│   └── wallet_service.dart     # WalletConnect
├── widgets/
│   ├── pokeagent_card.dart     # Agent display card
│   └── chat_bubble.dart        # Chat message bubble
└── utils/
    ├── constants.dart          # App configuration
    └── theme.dart              # Custom theme & colors
```

---

## 🎨 Design Highlights

- **Gradient Backgrounds**: Electric blue to violet
- **Glowing Cards**: Type-colored borders with shadows
- **XP Progress Bars**: Animated with type colors
- **Smooth Animations**: FadeIn, ZoomIn, Pulse effects
- **Poppins Font**: Clean, modern typography
- **Type Colors**:
  - 🔥 Fire: `#FF6B6B`
  - 💧 Water: `#4ECDC4`
  - ⚡ Electric: `#FFC233`
  - 🧠 Psychic: `#B794F6`
  - 🌿 Grass: `#51CF66`
  - ❄️ Ice: `#74C0FC`

---

## 🔗 Backend Setup (Optional)

For full functionality, deploy a backend with these endpoints:

### Required Endpoints

```javascript
POST /api/mint        // Mint NFT + generate AI image
POST /api/chat        // AI chat responses
POST /api/battle      // Simulate AI battles
POST /api/evolve      // Generate evolution data
```

### Example Backend (Node.js/Express)

```javascript
app.post('/api/chat', async (req, res) => {
  const { agentName, agentType, message, personality } = req.body;
  
  const prompt = `You are ${agentName}, a ${agentType} PokéAgent. 
    Respond playfully with Pokémon-style speech. ${personality}`;
  
  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [
      { role: 'system', content: prompt },
      { role: 'user', content: message }
    ]
  });
  
  res.json({ response: response.choices[0].message.content });
});
```

---

## 🚢 Deployment

### Frontend (Vercel)

```bash
flutter build web
cd build/web
vercel deploy
```

### Smart Contract (Base Sepolia)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PokeAgent is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    constructor() ERC721("PokeAgent", "POKE") {}

    function mint(address to, string memory uri) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }
}
```

Deploy using:
- **Remix IDE**: https://remix.ethereum.org
- **Hardhat**: `npx hardhat run scripts/deploy.js --network baseSepolia`
- **thirdweb**: https://thirdweb.com/

---

## 🎯 Roadmap

- [x] **v0.1**: Core minting, training, battles
- [ ] **v0.2**: Real blockchain integration
- [ ] **v0.3**: AI image generation (Stable Diffusion)
- [ ] **v0.4**: PvP battles with staking
- [ ] **v0.5**: Agent marketplace
- [ ] **v0.6**: Breeding system
- [ ] **v0.7**: Tournaments & leaderboards

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- **Base** for the L2 infrastructure
- **OpenAI** for AI capabilities
- **Flutter** team for the amazing framework
- **Pokémon** for inspiration (fan project, not affiliated)

---

<div align="center">

**Built with ❤️ for Pokéthon Hackathon**

⭐ Star this repo if you like it!

</div>
