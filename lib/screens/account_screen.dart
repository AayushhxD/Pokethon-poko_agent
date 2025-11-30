import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/user_stats_service.dart';
import 'home_screen.dart';
import 'regions_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import 'add_tokens_screen.dart';

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
      backgroundColor: Colors.white, // Changed to white
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Wallet Balance Card (if connected)
              if (walletService.isConnected)
                FadeInDown(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFD700),
                          const Color(0xFFFFA500),
                          const Color(0xFFFF8C00),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'POKO Balance',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      '🪙',
                                      style: TextStyle(fontSize: 28),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      walletService.formattedBalance,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Connected',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white.withOpacity(0.9),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  walletService.shortAddress,
                                  style: GoogleFonts.robotoMono(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Add Tokens Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddTokensScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 20,
                            ),
                            label: Text(
                              'Add POKO Tokens',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFFF8C00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (walletService.isConnected) const SizedBox(height: 20),

              // User Profile Section - Show if logged in
              Consumer<FirebaseAuthService>(
                builder: (context, authService, child) {
                  if (authService.isLoggedIn) {
                    return FadeInDown(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF3861FB),
                              const Color(0xFF5B7FFF),
                              const Color(0xFF7B9CFF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3861FB).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Profile Picture
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.2,
                                    ),
                                    backgroundImage:
                                        authService.currentUser?.photoURL !=
                                                null
                                            ? NetworkImage(
                                              authService
                                                  .currentUser!
                                                  .photoURL!,
                                            )
                                            : null,
                                    child:
                                        authService.currentUser?.photoURL ==
                                                null
                                            ? Text(
                                              (authService
                                                          .currentUser
                                                          ?.displayName ??
                                                      'U')[0]
                                                  .toUpperCase(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            )
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authService.currentUser?.displayName ??
                                            'Trainer',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        authService.currentUser?.email ?? '',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Verified Badge
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    authService.currentUser?.emailVerified ==
                                            true
                                        ? Icons.verified
                                        : Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Stats Row
                            Consumer<UserStatsService>(
                              builder: (context, statsService, child) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildProfileStat(
                                        'Pokémon',
                                        statsService.ownedPokemonCount
                                            .toString(),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      _buildProfileStat(
                                        'Battles',
                                        statsService.totalBattles.toString(),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      _buildProfileStat(
                                        'Wins',
                                        statsService.totalWins.toString(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  // Show registration card if not logged in
                  return Column(
                    children: [
                      // Header Text
                      FadeInDown(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Profile not registered',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
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
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
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
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3861FB),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign In or Sign Up',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Settings Container
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
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

                      const SizedBox(height: 24),

                      // Sign Out Section
                      _buildSectionHeader('Account'),
                      const SizedBox(height: 16),

                      Consumer<FirebaseAuthService>(
                        builder: (context, authService, child) {
                          if (authService.isLoggedIn) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User info
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: const Color(
                                          0xFF3861FB,
                                        ),
                                        backgroundImage:
                                            authService.currentUser?.photoURL !=
                                                    null
                                                ? NetworkImage(
                                                  authService
                                                      .currentUser!
                                                      .photoURL!,
                                                )
                                                : null,
                                        child:
                                            authService.currentUser?.photoURL ==
                                                    null
                                                ? Text(
                                                  (authService
                                                              .currentUser
                                                              ?.displayName ??
                                                          'U')[0]
                                                      .toUpperCase(),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                )
                                                : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              authService
                                                      .currentUser
                                                      ?.displayName ??
                                                  'Trainer',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              authService.currentUser?.email ??
                                                  '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Sign Out Button
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await authService.signOut();
                                      if (mounted) {
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const LoginScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      side: const BorderSide(
                                        color: Colors.red,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.logout_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    label: Text(
                                      'Sign Out',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return _buildInfoTile(
                            title: 'Sign In',
                            subtitle: 'Sign in to sync your progress',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                          );
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RegionsScreen()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            } else {
              // Already on Account
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFCD3131),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.catching_pokemon, size: 24),
              label: 'Pokedex',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_rounded, size: 24),
              label: 'Regions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded, size: 24),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 24),
              label: 'Account',
            ),
          ],
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
          activeTrackColor: const Color(0xFF3861FB).withValues(alpha: 0.5),
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

  // This file uses BottomNavigationBar directly so _buildBottomNavItem is not needed.

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

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
