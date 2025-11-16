import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService extends ChangeNotifier {
  String? _walletAddress;
  bool _isConnected = false;
  final SharedPreferences _prefs;

  WalletService(this._prefs) {
    _loadWalletData();
  }

  String? get walletAddress => _walletAddress;
  bool get isConnected => _isConnected;

  String get shortAddress {
    if (_walletAddress == null) return '';
    return '${_walletAddress!.substring(0, 6)}...${_walletAddress!.substring(_walletAddress!.length - 4)}';
  }

  // Load wallet data from local storage
  Future<void> _loadWalletData() async {
    _walletAddress = _prefs.getString('wallet_address');
    _isConnected = _walletAddress != null;
    notifyListeners();
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
        await _prefs.setString('wallet_address', _walletAddress!);
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
    _isConnected = false;
    await _prefs.remove('wallet_address');
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
