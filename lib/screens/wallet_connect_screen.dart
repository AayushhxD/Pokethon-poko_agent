import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  State<WalletConnectScreen> createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen>
    with TickerProviderStateMixin {
  bool _isConnecting = false;
  String? _connectedWallet;
  String? _walletAddress;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _wallets = [
    {
      'name': 'MetaMask',
      'icon': '🦊',
      'color': const Color(0xFFF6851B),
      'popular': true,
      'address': '0x149D84071CCB00913C96Db947fCb9000C1Da963C',
    },
    {
      'name': 'Freighter',
      'icon': '🚀',
      'color': const Color(0xFF3E1BDB),
      'popular': true,
      'address': 'GAFUOLLOBNLFDKDIJY2DUG4CLY7EBXQAEC3OWRQGMM5XCMV2MPAJBPNG',
    },
    {
      'name': 'Phantom',
      'icon': '👻',
      'color': const Color(0xFFAB9FF2),
      'popular': true,
    },
    {
      'name': 'Coinbase Wallet',
      'icon': '🔵',
      'color': const Color(0xFF0052FF),
      'popular': true,
    },
    {
      'name': 'Trust Wallet',
      'icon': '🛡️',
      'color': const Color(0xFF3375BB),
      'popular': false,
    },
    {
      'name': 'Rainbow',
      'icon': '🌈',
      'color': const Color(0xFF001E59),
      'popular': false,
    },
    {
      'name': 'WalletConnect',
      'icon': '🔗',
      'color': const Color(0xFF3B99FC),
      'popular': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _connectWallet(Map<String, dynamic> wallet) async {
    setState(() {
      _isConnecting = true;
      _connectedWallet = wallet['name'];
    });

    // Simulate wallet connection
    await Future.delayed(const Duration(seconds: 2));

    // Use specific address if available, otherwise generate mock
    final mockAddress = wallet['address'] ?? _generateMockAddress();

    setState(() {
      _isConnecting = false;
      _walletAddress = mockAddress;
    });

    // Save wallet info
    await _saveWalletInfo(wallet['name'], mockAddress);

    // Show success and navigate
    if (mounted) {
      _showSuccessDialog(wallet['name'], mockAddress);
    }
  }

  String _generateMockAddress() {
    const chars = '0123456789abcdef';
    String address = '0x';
    for (int i = 0; i < 40; i++) {
      address += chars[(DateTime.now().microsecond + i) % chars.length];
    }
    return address;
  }

  Future<void> _saveWalletInfo(String walletName, String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_name', walletName);
    await prefs.setString('wallet_address', address);
    await prefs.setBool('wallet_connected', true);
    // Set initial balance of 1000 POKO tokens
    await prefs.setDouble('wallet_balance', 1000.0);
    // Set initial crypto balance based on wallet type
    double cryptoBalance = 0.0;
    if (walletName.toLowerCase().contains('metamask')) {
      cryptoBalance = 0.2847; // ETH
    } else if (walletName.toLowerCase().contains('freighter')) {
      cryptoBalance = 1250.50; // XLM
    } else if (walletName.toLowerCase().contains('phantom')) {
      cryptoBalance = 2.156; // SOL
    } else {
      cryptoBalance = 0.1523; // Default ETH
    }
    await prefs.setDouble('crypto_balance', cryptoBalance);
  }

  void _showSuccessDialog(String walletName, String address) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success animation
                  ZoomIn(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Wallet Connected!',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17171B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    walletName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3861FB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Wallet address
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '${address.substring(0, 6)}...${address.substring(address.length - 4)}',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: address));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Address copied!',
                                  style: GoogleFonts.poppins(),
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: const Color(0xFF3861FB),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF3861FB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue to App',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _skipForNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wallet_skipped', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      'Connect Wallet',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF17171B),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _skipForNow,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Wallet illustration with Pokemon image
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF3861FB).withOpacity(0.1),
                                const Color(0xFF6C63FF).withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/lucario 1.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Connect Your Wallet',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF17171B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Connect your wallet to unlock exclusive features,\ntrade Pokémon NFTs, and earn rewards!',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF747476),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Features list
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureRow(
                              Icons.swap_horiz,
                              'Trade Pokémon NFTs',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureRow(Icons.star, 'Earn POKO tokens'),
                            const SizedBox(height: 12),
                            _buildFeatureRow(
                              Icons.lock_open,
                              'Unlock exclusive content',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Popular wallets label
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 600),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Popular Wallets',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF17171B),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Wallet options
                    ...List.generate(_wallets.length, (index) {
                      final wallet = _wallets[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 500 + (index * 100)),
                        duration: const Duration(milliseconds: 600),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildWalletOption(wallet),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Security note
                    FadeInUp(
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE082)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.security,
                              color: Color(0xFFFF8F00),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your wallet credentials are never stored on our servers. You maintain full control.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF5D4037),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF3861FB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3861FB), size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF17171B),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletOption(Map<String, dynamic> wallet) {
    final bool isConnecting =
        _isConnecting && _connectedWallet == wallet['name'];
    final bool isConnected =
        _walletAddress != null && _connectedWallet == wallet['name'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isConnecting ? null : () => _connectWallet(wallet),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isConnected
                      ? const Color(0xFF4CAF50)
                      : isConnecting
                      ? const Color(0xFF3861FB)
                      : const Color(0xFFE0E0E0),
              width: isConnected || isConnecting ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Wallet icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (wallet['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    wallet['icon'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Wallet name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          wallet['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF17171B),
                          ),
                        ),
                        if (wallet['popular'] == true) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3861FB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Popular',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3861FB),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isConnected)
                      Text(
                        'Connected',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                  ],
                ),
              ),
              // Status indicator
              if (isConnecting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF3861FB),
                    ),
                  ),
                )
              else if (isConnected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 24,
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
