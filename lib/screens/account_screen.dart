import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Account',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3861FB).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF3861FB),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PokéTrainer',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            walletService.isConnected
                                ? walletService.shortAddress
                                : 'Not connected',
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Menu Items
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Account Settings',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Wallet Connection
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildMenuItem(
                icon: Icons.account_balance_wallet,
                title: 'Wallet',
                subtitle:
                    walletService.isConnected
                        ? 'Connected to ${walletService.shortAddress}'
                        : 'Connect your wallet',
                onTap: () async {
                  if (!walletService.isConnected) {
                    await walletService.connectWallet();
                  }
                },
                trailing:
                    walletService.isConnected
                        ? Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        )
                        : const Icon(Icons.chevron_right),
              ),
            ),

            // Statistics
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildMenuItem(
                icon: Icons.bar_chart,
                title: 'Statistics',
                subtitle: 'View your PokéAgent stats',
                onTap: () {
                  // TODO: Navigate to statistics screen
                },
              ),
            ),

            // Achievements
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _buildMenuItem(
                icon: Icons.emoji_events,
                title: 'Achievements',
                subtitle: 'View your badges and rewards',
                onTap: () {
                  // TODO: Navigate to achievements screen
                },
              ),
            ),

            // Settings
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: _buildMenuItem(
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'App preferences and configuration',
                onTap: () {
                  // TODO: Navigate to settings screen
                },
              ),
            ),

            // Help & Support
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () {
                  // TODO: Navigate to help screen
                },
              ),
            ),

            const SizedBox(height: 32),

            // Sign Out
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate back to login
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: Color(0xFFCD3131),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFCD3131),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3861FB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3861FB), size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
