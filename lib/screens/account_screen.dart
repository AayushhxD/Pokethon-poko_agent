import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _megaEvolutionsEnabled = false;
  bool _otherFormsEnabled = false;
  bool _pokedexUpdatesEnabled = true;
  bool _pokemonWorldEnabled = true;

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F36),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header Text
              FadeInDown(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Profile not registered',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Registration Card
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Pokemon Character Image Placeholder
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.catching_pokemon,
                              size: 50,
                              color: Colors.cyan.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Character Image Placeholder
                          Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Keep your Pokédex up to date and participate in this world.',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign In / Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF3861FB),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                color: Color(0xFF3861FB),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Sign In or Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3861FB),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Settings Container
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pokedex Section
                      _buildSectionHeader('Pokédex'),
                      const SizedBox(height: 16),

                      _buildToggleTile(
                        title: 'Mega evolutions',
                        subtitle: 'Enable mega evolution display',
                        value: _megaEvolutionsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _megaEvolutionsEnabled = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildToggleTile(
                        title: 'Other forms',
                        subtitle: 'Enable alternate form display',
                        value: _otherFormsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _otherFormsEnabled = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Notifications Section
                      _buildSectionHeader('Notifications'),
                      const SizedBox(height: 16),

                      _buildToggleTile(
                        title: 'Pokédex updates',
                        subtitle: 'New Pokémon, abilities, info, etc.',
                        value: _pokedexUpdatesEnabled,
                        onChanged: (value) {
                          setState(() {
                            _pokedexUpdatesEnabled = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildToggleTile(
                        title: 'Pokémon World',
                        subtitle: 'Events and news from Pokémon world',
                        value: _pokemonWorldEnabled,
                        onChanged: (value) {
                          setState(() {
                            _pokemonWorldEnabled = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Language Section
                      _buildSectionHeader('Language'),
                      const SizedBox(height: 16),

                      _buildInfoTile(
                        title: 'Interface language',
                        subtitle: 'Portuguese (PT-BR)',
                        onTap: () {
                          _showLanguageDialog('interface');
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildInfoTile(
                        title: 'Game info language',
                        subtitle: 'English (US)',
                        onTap: () {
                          _showLanguageDialog('game');
                        },
                      ),

                      const SizedBox(height: 24),

                      // General Section
                      _buildSectionHeader('General'),
                      const SizedBox(height: 16),

                      _buildInfoTile(
                        title: 'Version',
                        subtitle: '0.8.12',
                        onTap: null,
                        showArrow: false,
                      ),

                      const SizedBox(height: 12),

                      _buildInfoTile(
                        title: 'Terms and conditions',
                        subtitle: 'Everything you need to know',
                        onTap: () {
                          // Show terms
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildInfoTile(
                        title: 'Help center',
                        subtitle: 'Need help? Contact us',
                        onTap: () {
                          // Show help
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildInfoTile(
                        title: 'About',
                        subtitle: 'Learn more about the app',
                        onTap: () {
                          // Show about
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F36),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.explore_outlined, false),
                _buildBottomNavItem(Icons.location_on_outlined, false),
                _buildBottomNavItem(Icons.favorite_border, false),
                _buildBottomNavItem(Icons.person, true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF3861FB),
          activeTrackColor: const Color(0xFF3861FB).withOpacity(0.5),
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isActive ? const Color(0xFFCD3131) : Colors.white54,
        size: 28,
      ),
    );
  }

  void _showLanguageDialog(String type) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              type == 'interface' ? 'Interface Language' : 'Game Info Language',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption('English (US)', type),
                _buildLanguageOption('Portuguese (PT-BR)', type),
                _buildLanguageOption('Spanish (ES)', type),
                _buildLanguageOption('French (FR)', type),
                _buildLanguageOption('German (DE)', type),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3861FB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildLanguageOption(String language, String type) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Language changed to $language',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF3861FB),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ),
            Icon(
              Icons.check_circle,
              color:
                  language.contains('English')
                      ? const Color(0xFF3861FB)
                      : Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
