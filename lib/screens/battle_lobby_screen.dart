import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/pokeagent.dart';
import '../services/wallet_service.dart';
import '../utils/theme.dart';
import '../widgets/pokeagent_card.dart';
import 'battle_matchmaking_screen.dart';
import 'nft_inventory_screen.dart';

class BattleLobbyScreen extends StatefulWidget {
  final PokeAgent? selectedAgent;
  final Function(PokeAgent?) onAgentChanged;

  const BattleLobbyScreen({
    super.key,
    this.selectedAgent,
    required this.onAgentChanged,
  });

  @override
  State<BattleLobbyScreen> createState() => _BattleLobbyScreenState();
}

class _BattleLobbyScreenState extends State<BattleLobbyScreen> {
  PokeAgent? _selectedAgent;

  @override
  void initState() {
    super.initState();
    _selectedAgent = widget.selectedAgent;
  }

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSelectedCreatureCard(),
                      const SizedBox(height: 30),
                      _buildStatsSection(),
                      const SizedBox(height: 30),
                      _buildActionButtons(),
                      const SizedBox(height: 30),
                      _buildRecentBattles(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            'Battle Lobby',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 16,
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
    );
  }

  Widget _buildSelectedCreatureCard() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              'Selected Creature',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedAgent != null)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getTypeColor(
                        _selectedAgent!.type,
                      ).withOpacity(0.3),
                      AppTheme.getTypeColor(
                        _selectedAgent!.type,
                      ).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.getTypeColor(_selectedAgent!.type),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.catching_pokemon,
                  size: 80,
                  color: Colors.white,
                ),
              )
            else
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(Icons.add, size: 60, color: Colors.white54),
              ),
            const SizedBox(height: 16),
            Text(
              _selectedAgent?.name ?? 'No Creature Selected',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (_selectedAgent != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getTypeColor(
                    _selectedAgent!.type,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedAgent!.type} • Lv.${_selectedAgent!.level}',
                  style: GoogleFonts.poppins(
                    color: AppTheme.getTypeColor(_selectedAgent!.type),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_selectedAgent == null) return const SizedBox.shrink();

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Battle Stats',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatBar(
              'HP',
              _selectedAgent!.stats['hp']! / 100,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildStatBar(
              'Attack',
              _selectedAgent!.stats['attack']! / 100,
              Colors.red,
            ),
            const SizedBox(height: 16),
            _buildStatBar(
              'Defense',
              _selectedAgent!.stats['defense']! / 100,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildStatBar(
              'Speed',
              _selectedAgent!.stats['speed']! / 100,
              Colors.yellow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(value * 100).toInt()}',
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedAgent != null ? _findOpponent : null,
              icon: const Icon(Icons.search),
              label: const Text('Find Opponent'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    _selectedAgent != null ? Colors.orange : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _switchCreature,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Switch Creature'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.white, width: 2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBattles() {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Battles',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentBattleItem(
              'Victory vs Charizard',
              '+25 XP',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildRecentBattleItem('Defeat vs Pikachu', '+10 XP', Colors.red),
            const SizedBox(height: 12),
            _buildRecentBattleItem(
              'Victory vs Squirtle',
              '+30 XP',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBattleItem(String title, String xp, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            xp,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _findOpponent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                BattleMatchmakingScreen(selectedAgent: _selectedAgent!),
      ),
    );
  }

  void _switchCreature() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NftInventoryScreen()),
    ).then((selectedAgent) {
      if (selectedAgent != null && selectedAgent is PokeAgent) {
        setState(() {
          _selectedAgent = selectedAgent;
        });
        widget.onAgentChanged(selectedAgent);
      }
    });
  }
}
