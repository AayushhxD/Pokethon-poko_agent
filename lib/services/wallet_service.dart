import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService extends ChangeNotifier {
  String? _walletAddress;
  String? _walletName;
  bool _isConnected = false;
  double _balance = 0.0;
  double _cryptoBalance = 0.0; // ETH or XLM balance
  final SharedPreferences _prefs;

  // Cost constants for different actions
  static const double mintCost = 50.0;
  static const double battleCost = 10.0;
  static const double evolveCost = 100.0;
  static const double trainCost = 5.0;
  static const double catchCost = 20.0;

  WalletService(this._prefs) {
    _loadWalletData();
  }

  String? get walletAddress => _walletAddress;
  String? get walletName => _walletName;
  bool get isConnected => _isConnected;
  double get balance => _balance;
  double get cryptoBalance => _cryptoBalance;

  // Get crypto currency symbol based on wallet type
  String get cryptoSymbol {
    if (_walletName == null) return 'ETH';
    if (_walletName!.toLowerCase().contains('freighter')) return 'XLM';
    if (_walletName!.toLowerCase().contains('phantom')) return 'SOL';
    return 'ETH'; // Default for MetaMask and others
  }

  // Get crypto icon based on wallet type
  String get cryptoIcon {
    if (_walletName == null) return '⟠';
    if (_walletName!.toLowerCase().contains('freighter')) return '✦';
    if (_walletName!.toLowerCase().contains('phantom')) return '◎';
    return '⟠'; // ETH icon
  }

  String get shortAddress {
    if (_walletAddress == null) return '';
    return '${_walletAddress!.substring(0, 6)}...${_walletAddress!.substring(_walletAddress!.length - 4)}';
  }

  String get formattedBalance {
    return _balance.toStringAsFixed(2);
  }

  String get formattedCryptoBalance {
    return _cryptoBalance.toStringAsFixed(4);
  }

  // Load wallet data from local storage
  Future<void> _loadWalletData() async {
    _walletAddress = _prefs.getString('wallet_address');
    _walletName = _prefs.getString('wallet_name');
    _isConnected = _prefs.getBool('wallet_connected') ?? false;
    _balance = _prefs.getDouble('wallet_balance') ?? 0.0;
    _cryptoBalance = _prefs.getDouble('crypto_balance') ?? 0.0;
    notifyListeners();
  }

  // Save balance to local storage
  Future<void> _saveBalance() async {
    await _prefs.setDouble('wallet_balance', _balance);
    await _prefs.setDouble('crypto_balance', _cryptoBalance);
    notifyListeners();
  }

  // Set initial balance (called when wallet is connected)
  Future<void> setInitialBalance(double amount) async {
    _balance = amount;
    await _saveBalance();
  }

  // Add tokens to balance (rewards, etc.)
  Future<void> addTokens(double amount) async {
    _balance += amount;
    await _saveBalance();
  }

  // Deduct tokens from balance (costs)
  Future<bool> deductTokens(double amount) async {
    if (_cryptoBalance >= amount) {
      _cryptoBalance -= amount;
      await _saveBalance();
      return true;
    }
    return false;
  }

  // Deduct from regular token balance
  Future<bool> deductRegularTokens(double amount) async {
    if (_balance >= amount) {
      _balance -= amount;
      await _saveBalance();
      return true;
    }
    return false;
  }

  // Add crypto balance (ETH/SOL/XLM)
  Future<void> addCryptoBalance(double amount) async {
    _cryptoBalance += amount;
    await _saveBalance();
  }

  // Check if user has enough crypto balance
  bool hasEnoughCryptoBalance(double amount) {
    return _cryptoBalance >= amount;
  }

  // Check if user has enough balance
  bool hasEnoughBalance(double amount) {
    return _balance >= amount;
  }

  // Connect wallet (WalletConnect integration)
  Future<bool> connectWallet() async {
    try {
      // In production, implement WalletConnect v2
      // For demo purposes, we'll simulate a connection

      // Simulated wallet address for demo
      if (kDebugMode) {
        _walletAddress = '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb';
        _isConnected = true;
        // Only set initial balance if no existing balance (preserve tokens across sessions)
        final existingBalance = _prefs.getDouble('wallet_balance');
        if (existingBalance == null || existingBalance == 0) {
          _balance = 1000.0; // Initial balance for new users only
        } else {
          _balance = existingBalance;
        }
        await _prefs.setString('wallet_address', _walletAddress!);
        await _prefs.setBool('wallet_connected', true);
        await _prefs.setDouble('wallet_balance', _balance);
        notifyListeners();
        return true;
      }

      /* Production WalletConnect implementation:
      final wcClient = WalletConnectModalFlutter();
      await wcClient.init(
        projectId: 'YOUR_PROJECT_ID',
        metadata: PairingMetadata(
          name: 'PokéAgents',
          description: 'AI-powered NFT agents on Base',
          url: 'https://pokeagents.app',
          icons: ['https://pokeagents.app/icon.png'],
        ),
      );
      
      final session = await wcClient.connect();
      _walletAddress = session.accounts.first;
      _isConnected = true;
      await _prefs.setString('wallet_address', _walletAddress!);
      notifyListeners();
      return true;
      */

      return false;
    } catch (e) {
      debugPrint('Failed to connect wallet: $e');
      return false;
    }
  }

  // Disconnect wallet
  Future<void> disconnectWallet() async {
    _walletAddress = null;
    _walletName = null;
    _isConnected = false;
    _balance = 0.0;
    _cryptoBalance = 0.0;
    await _prefs.remove('wallet_address');
    await _prefs.remove('wallet_name');
    await _prefs.remove('wallet_connected');
    await _prefs.remove('wallet_balance');
    await _prefs.remove('crypto_balance');
    notifyListeners();
  }

  // Sign message (for authentication)
  Future<String?> signMessage(String message) async {
    try {
      // Implement message signing with WalletConnect
      // For demo, return mock signature
      return '0x${'a' * 130}';
    } catch (e) {
      debugPrint('Failed to sign message: $e');
      return null;
    }
  }

  // Send transaction
  Future<String?> sendTransaction({
    required String to,
    required String value,
    String? data,
  }) async {
    try {
      // Implement transaction sending with WalletConnect
      // For demo, return mock tx hash
      return '0x${'b' * 64}';
    } catch (e) {
      debugPrint('Failed to send transaction: $e');
      return null;
    }
  }
}
