# 🚀 Quick Start Guide - PokéAgents

## Get Up and Running in 5 Minutes!

### Step 1: Install Dependencies
```powershell
flutter pub get
```

### Step 2: Run the App
```powershell
# For Web (Recommended for demo)
flutter run -d chrome

# For Android
flutter run -d android

# For iOS (macOS only)
flutter run -d ios
```

### Step 3: Try the Demo Features

The app works **out of the box** with demo/fallback features:

#### ✅ What Works Immediately:
- 🎨 **Mint Agents**: Create agents with different types
- 💬 **Train**: Chat interface with fallback AI responses
- ⚔️ **Battle**: AI-simulated battles with animations
- ✨ **Evolve**: Evolution system with stat boosts
- 💾 **Local Storage**: Agents saved locally
- 🎭 **Beautiful UI**: All animations and themes

#### 🔧 What Needs Backend (Optional):
- Real OpenAI/Claude chat responses
- AI-generated agent images
- Blockchain NFT minting on Base
- IPFS metadata storage
- Real wallet integration

---

## 🎮 Demo Flow

### 1. Splash Screen
- Beautiful animated Pokéball
- "Enter the Arena" button

### 2. Home Screen
- Connect wallet (demo mode available)
- View your agent collection
- Mint new agents

### 3. Mint Screen
- Select type: Fire, Water, Electric, Psychic, Grass, Ice
- Enter agent name
- Instant minting (local for demo)

### 4. Train Screen
- Chat with your agent
- Earn 5 XP per message
- Watch XP progress bar fill up

### 5. Battle Screen
- Select opponent from your agents
- Watch animated battle
- Win: +20 XP, Lose: +5 XP

### 6. Evolution Screen
- Available at 100, 300, 600 XP thresholds
- Stat boosts on evolution
- Stage progression

---

## 🛠️ Configuration (Optional)

### For Backend Integration

Edit `lib/utils/constants.dart`:

```dart
static const String baseApiUrl = 'YOUR_BACKEND_URL';
static const String pokeAgentContractAddress = 'YOUR_CONTRACT';
static const String nftStorageApiKey = 'YOUR_NFT_STORAGE_KEY';
```

### For Real Wallet Connection

Update `lib/services/wallet_service.dart`:

```dart
// Add your WalletConnect Project ID
final wcClient = WalletConnectModalFlutter();
await wcClient.init(
  projectId: 'YOUR_WALLETCONNECT_PROJECT_ID',
  // ...
);
```

---

## 🐛 Troubleshooting

### Issue: Dependencies not resolving
```powershell
flutter clean
flutter pub get
```

### Issue: Web app not loading
```powershell
flutter run -d chrome --web-renderer html
```

### Issue: Gradle build errors (Android)
```powershell
cd android
./gradlew clean
cd ..
flutter run
```

---

## 📱 Testing on Different Platforms

### Web (Easiest)
```powershell
flutter run -d chrome
```

### Android Emulator
1. Open Android Studio
2. Start an emulator
3. Run: `flutter run`

### iOS Simulator (macOS only)
1. Open Xcode
2. Start iOS Simulator
3. Run: `flutter run`

### Physical Device
1. Enable Developer Mode on device
2. Connect via USB
3. Run: `flutter devices` to see device
4. Run: `flutter run -d <device-id>`

---

## 🎨 Customization Tips

### Change Theme Colors
Edit `lib/utils/theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6366F1); // Your color
static const Color secondaryColor = Color(0xFF8B5CF6); // Your color
```

### Add Custom Agent Types
Edit `lib/utils/constants.dart`:
```dart
static const List<String> agentTypes = [
  'Fire', 'Water', 'Electric', 'Psychic', 'Grass', 'Ice',
  'Dragon', 'Dark', 'Fairy' // Add more!
];
```

### Adjust XP Rewards
Edit `lib/utils/constants.dart`:
```dart
static const int chatXPReward = 10; // Increase training rewards
static const int battleWinXPReward = 30; // Increase battle rewards
```

---

## 📦 Building for Production

### Web Build
```powershell
flutter build web --release
# Output: build/web/
# Deploy to: Vercel, Netlify, Firebase Hosting
```

### Android APK
```powershell
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS App
```powershell
flutter build ios --release
# Open: ios/Runner.xcworkspace in Xcode
# Archive and submit to App Store
```

---

## 🚀 Deploy to Vercel (Web)

```powershell
# Build the app
flutter build web --release

# Install Vercel CLI
npm i -g vercel

# Deploy
cd build/web
vercel deploy --prod
```

---

## 🎯 Next Steps

1. **Test locally** - Run the app and try all features
2. **Deploy backend** - Set up Node.js backend for AI features
3. **Deploy contract** - Deploy ERC-721 contract to Base
4. **Add real wallet** - Integrate WalletConnect properly
5. **Generate images** - Connect to Stable Diffusion API
6. **Deploy frontend** - Host on Vercel

---

## 💡 Pro Tips

- Use **Chrome DevTools** for debugging web version
- Check `flutter doctor` for any setup issues
- Use **hot reload** (`r` in terminal) while developing
- Test on actual devices for best experience
- Keep Backend API keys in `.env` files

---

## 🆘 Need Help?

- **Flutter Docs**: https://docs.flutter.dev
- **Base Docs**: https://docs.base.org
- **WalletConnect**: https://docs.walletconnect.com
- **Web3dart**: https://pub.dev/packages/web3dart

---

**Happy Building! 🎉**

Built with ❤️ by you for Pokéthon
