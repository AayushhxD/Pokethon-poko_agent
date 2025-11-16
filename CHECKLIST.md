# ✅ Pre-Launch Checklist

## 🔍 Before Running

### 1. Flutter Setup
- [ ] Run `flutter doctor` - All checkmarks green
- [ ] Flutter version 3.7.2+
- [ ] Dart SDK installed

### 2. Dependencies
```powershell
flutter pub get
```
- [ ] All packages downloaded successfully
- [ ] No dependency conflicts

### 3. Environment Check
- [ ] Assets directories created (`assets/images`, `assets/animations`)
- [ ] No compile errors
- [ ] `analysis_options.yaml` configured

---

## 🚀 Launch Steps

### Step 1: Test Locally
```powershell
flutter run -d chrome
```

**Expected Results:**
- [ ] Splash screen shows animated Pokéball
- [ ] "Enter the Arena" button works
- [ ] Home screen loads
- [ ] "Connect Wallet" shows demo address

### Step 2: Test Minting
- [ ] Click "Mint Agent"
- [ ] Select a type (e.g., Electric)
- [ ] Enter name (e.g., "Pikachu")
- [ ] Agent appears in collection

### Step 3: Test Training
- [ ] Tap agent card
- [ ] Select "Train"
- [ ] Send message: "Hello!"
- [ ] Agent responds with fallback message
- [ ] XP increases by 5

### Step 4: Test Battle
- [ ] Mint at least 2 agents
- [ ] Select "Battle"
- [ ] Choose opponent
- [ ] Battle animation plays
- [ ] Winner declared
- [ ] XP increases

### Step 5: Test Evolution
- [ ] Train agent to 100+ XP
- [ ] Select "Evolve"
- [ ] Evolution animation plays
- [ ] Stats increase
- [ ] Stage upgrades to 2

---

## 🔧 Optional Configurations

### Backend Integration
- [ ] Deploy Node.js backend to Vercel
- [ ] Get OpenAI API key
- [ ] Update `lib/utils/constants.dart`:
  ```dart
  static const String baseApiUrl = 'YOUR_VERCEL_URL';
  ```

### Blockchain Integration
- [ ] Deploy smart contract to Base Sepolia
- [ ] Get contract address
- [ ] Update `lib/utils/constants.dart`:
  ```dart
  static const String pokeAgentContractAddress = '0xYOUR_ADDRESS';
  ```

### Wallet Integration
- [ ] Get WalletConnect Project ID
- [ ] Update `lib/services/wallet_service.dart`
- [ ] Test wallet connection

### IPFS Integration
- [ ] Get NFT.storage API key
- [ ] Update `lib/utils/constants.dart`:
  ```dart
  static const String nftStorageApiKey = 'YOUR_KEY';
  ```

---

## 📱 Platform Testing

### Web
```powershell
flutter run -d chrome
```
- [ ] Chrome/Edge
- [ ] Firefox
- [ ] Safari

### Mobile
```powershell
flutter run
```
- [ ] Android emulator
- [ ] iOS simulator (macOS)
- [ ] Physical device

---

## 🎨 Customization Checklist

### Theme
`lib/utils/theme.dart`
- [ ] Primary color: `#6366F1` → Your color
- [ ] Secondary color: `#8B5CF6` → Your color
- [ ] Type colors customized

### Constants
`lib/utils/constants.dart`
- [ ] XP rewards adjusted
- [ ] Evolution thresholds set
- [ ] Agent types configured

### Assets
- [ ] Add custom images to `assets/images/`
- [ ] Add Lottie animations to `assets/animations/`
- [ ] Update `pubspec.yaml` if needed

---

## 🚢 Deployment Checklist

### Frontend (Vercel)
```powershell
flutter build web --release
cd build/web
vercel deploy --prod
```
- [ ] Build successful
- [ ] Deployed to Vercel
- [ ] Custom domain configured
- [ ] HTTPS enabled

### Backend (Vercel)
```powershell
cd backend-example
vercel deploy --prod
```
- [ ] Environment variables set
- [ ] API endpoints working
- [ ] CORS configured

### Smart Contract
- [ ] Compiled without errors
- [ ] Deployed to testnet
- [ ] Verified on Basescan
- [ ] Contract address recorded

---

## 📊 Performance Checklist

### Code Quality
- [ ] No lint errors: `flutter analyze`
- [ ] No unused imports
- [ ] Code formatted: `flutter format .`

### Optimization
- [ ] Images optimized
- [ ] Build size reasonable
- [ ] Loading times acceptable
- [ ] Smooth animations

### Security
- [ ] No hardcoded private keys
- [ ] API keys in environment variables
- [ ] Proper error handling
- [ ] Input validation

---

## 📚 Documentation Checklist

- [x] README.md - Complete overview
- [x] QUICKSTART.md - Getting started guide
- [x] PROJECT_SUMMARY.md - Full project details
- [x] Backend README - API documentation
- [x] Contract DEPLOYMENT.md - Blockchain guide
- [ ] Add screenshots to README
- [ ] Create demo video
- [ ] Write blog post

---

## 🎥 Demo Preparation

### Screenshots Needed
- [ ] Splash screen
- [ ] Home screen (with agents)
- [ ] Mint screen
- [ ] Training chat
- [ ] Battle arena
- [ ] Evolution screen

### Demo Video
- [ ] Record 2-minute demo
- [ ] Show all features
- [ ] Add voiceover
- [ ] Upload to YouTube

### Pitch Deck
- [ ] Problem statement
- [ ] Solution (PokéAgents)
- [ ] Tech stack
- [ ] Demo walkthrough
- [ ] Roadmap
- [ ] Team

---

## 🏆 Hackathon Submission

### Required
- [ ] Project deployed and accessible
- [ ] GitHub repo public
- [ ] README with setup instructions
- [ ] Demo video
- [ ] Presentation deck

### Nice to Have
- [ ] Live demo ready
- [ ] Test accounts prepared
- [ ] Q&A answers prepared
- [ ] Future roadmap
- [ ] Community/social links

---

## 🐛 Common Issues & Fixes

### Issue: Build errors
```powershell
flutter clean
flutter pub get
flutter run
```

### Issue: Dependencies conflict
```powershell
# Check pubspec.yaml versions
# Update to compatible versions
flutter pub upgrade
```

### Issue: Web not loading
```powershell
flutter run -d chrome --web-renderer html
```

### Issue: Hot reload not working
```powershell
# Press R in terminal for hot restart
# Or restart app completely
```

---

## ✨ Final Checks

### Before Submitting
- [ ] App runs without errors
- [ ] All features work
- [ ] Demo tested multiple times
- [ ] README up to date
- [ ] Code commented
- [ ] No console errors
- [ ] Responsive on mobile

### After Submission
- [ ] Share on social media
- [ ] Join community Discord
- [ ] Gather feedback
- [ ] Plan next version
- [ ] Thank judges and organizers

---

## 🎉 Launch Command

When everything is checked:

```powershell
# Development
flutter run -d chrome

# Production
flutter build web --release
vercel deploy --prod
```

---

## 📞 Emergency Contacts

### Technical Issues
- Flutter Discord: https://discord.gg/flutter
- Base Discord: https://discord.gg/buildonbase
- Stack Overflow: flutter + web3 tags

### Help Needed?
Re-read:
1. `QUICKSTART.md` - Basic setup
2. `README.md` - Feature overview
3. `PROJECT_SUMMARY.md` - Complete guide

---

<div align="center">

## 🚀 Ready to Ship!

**All systems go! 🎮⚡**

```powershell
flutter pub get && flutter run -d chrome
```

</div>

---

**Good luck with your hackathon! 🏆**
