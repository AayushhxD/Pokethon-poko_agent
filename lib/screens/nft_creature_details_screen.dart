import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokeagent.dart';
import '../utils/theme.dart';

class NftCreatureDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> creature;

  const NftCreatureDetailsScreen({super.key, required this.creature});

  @override
  State<NftCreatureDetailsScreen> createState() =>
      _NftCreatureDetailsScreenState();
}

class _NftCreatureDetailsScreenState extends State<NftCreatureDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.creature['backgroundColor'].withOpacity(0.8),
              widget.creature['backgroundColor'].withOpacity(0.4),
              Colors.black.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCreatureDisplay(),
                      const SizedBox(height: 30),
                      _buildNftMetadata(),
                      const SizedBox(height: 30),
                      _buildStatsSection(),
                      const SizedBox(height: 30),
                      _buildSkillsSection(),
                      const SizedBox(height: 30),
                      _buildActionButtons(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.creature['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'NFT #${widget.creature['id']}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getRarityColor(widget.creature['rarity']),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.creature['rarity'],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatureDisplay() {
    return FadeIn(
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  widget.creature['backgroundColor'].withOpacity(
                    0.3 + _backgroundController.value * 0.2,
                  ),
                  widget.creature['backgroundColor'].withOpacity(
                    0.1 + _backgroundController.value * 0.1,
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: widget.creature['backgroundColor'].withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.creature['backgroundColor'].withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(20, (index) {
                  final delay = index * 0.1;
                  return Positioned(
                    left: (index * 50) % 300.0,
                    top: (index * 30) % 250.0,
                    child: FadeIn(
                      delay: Duration(milliseconds: (delay * 1000).toInt()),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),

                // Creature
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ZoomIn(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.catching_pokemon,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeInUp(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flash_on,
                                color: Colors.yellow,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Power: ${widget.creature['power']}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNftMetadata() {
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
              'NFT Metadata',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildMetadataRow('Token ID', '#${widget.creature['id']}'),
            const SizedBox(height: 12),
            _buildMetadataRow('Power Score', '${widget.creature['power']}'),
            const SizedBox(height: 12),
            _buildMetadataRow('Generation', '${widget.creature['generation']}'),
            const SizedBox(height: 12),
            _buildMetadataRow('Rarity', widget.creature['rarity']),
            const SizedBox(height: 12),
            _buildMetadataRow('Type', widget.creature['type']),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
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
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatBar('HP', 85, Colors.green),
            const SizedBox(height: 16),
            _buildStatBar('Attack', 90, Colors.red),
            const SizedBox(height: 16),
            _buildStatBar('Defense', 75, Colors.blue),
            const SizedBox(height: 16),
            _buildStatBar('Speed', 80, Colors.yellow),
            const SizedBox(height: 16),
            _buildStatBar('Special', 95, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
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
              '$value',
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
              value: value / 100,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
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
              'Skills & Abilities',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  (widget.creature['skills'] as List<String>).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.creature['backgroundColor'].withOpacity(
                          0.2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.creature['backgroundColor'].withOpacity(
                            0.5,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        skill,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeInUp(
      delay: const Duration(milliseconds: 800),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _setAsBattleCreature,
              icon: const Icon(Icons.sports_kabaddi),
              label: const Text('Set as Battle Creature'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _sellInMarketplace,
              icon: const Icon(Icons.sell),
              label: const Text('Sell in Marketplace'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.orange, width: 2),
                foregroundColor: Colors.orange,
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

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Common':
        return Colors.grey;
      case 'Rare':
        return Colors.blue;
      case 'Epic':
        return Colors.purple;
      case 'Legendary':
        return Colors.orange;
      case 'Mythical':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void _setAsBattleCreature() {
    // Create PokeAgent from creature data
    final pokeAgent = PokeAgent(
      id: widget.creature['id'],
      name: widget.creature['name'],
      type: widget.creature['type'],
      imageUrl: widget.creature['imageUrl'],
      xp: widget.creature['level'] * 100,
      evolutionStage: 1,
      personality: 'confident',
      mood: 'ready',
      moodLevel: 90,
      isFavorite: true,
    );

    Navigator.pop(context, pokeAgent);
  }

  void _sellInMarketplace() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.creature['name']} listed for sale!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
