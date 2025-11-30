import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trading_models.dart';
import '../models/pokeagent.dart';
import '../services/trading_service.dart';
import '../services/wallet_service.dart';
import '../services/user_stats_service.dart';

class NFTDetailScreen extends StatefulWidget {
  final NFTListing listing;

  const NFTDetailScreen({super.key, required this.listing});

  @override
  State<NFTDetailScreen> createState() => _NFTDetailScreenState();
}

class _NFTDetailScreenState extends State<NFTDetailScreen> {
  // Pokemon type colors
  final Map<String, Color> _typeColors = {
    'Fire': const Color(0xFFFB6C6C),
    'Water': const Color(0xFF77BDFE),
    'Grass': const Color(0xFF48D0B0),
    'Electric': const Color(0xFFFFCE4B),
    'Normal': const Color(0xFFA0A29F),
    'Ice': const Color(0xFF8ED8D8),
    'Fighting': const Color(0xFFD56723),
    'Poison': const Color(0xFFB97FC9),
    'Ground': const Color(0xFFD9B34A),
    'Flying': const Color(0xFFA890F0),
    'Psychic': const Color(0xFFFA6B8A),
    'Bug': const Color(0xFFA8B820),
    'Rock': const Color(0xFFB8A038),
    'Ghost': const Color(0xFF705898),
    'Dragon': const Color(0xFF7038F8),
    'Dark': const Color(0xFF705848),
    'Steel': const Color(0xFFB8B8D0),
    'Fairy': const Color(0xFFEE99AC),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPokemonInfo(),
                _buildPriceSection(),
                _buildPriceChart(),
                _buildStats(),
                _buildDescription(),
                _buildBidHistory(),
                _buildSellerInfo(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildAppBar() {
    final typeColor = _getTypeColor(widget.listing.pokemon.type);
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey.shade700,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<TradingService>(
          builder: (context, service, _) {
            final isWatched = service.isInWatchlist(widget.listing.id);
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  isWatched ? Icons.favorite : Icons.favorite_border,
                  color: isWatched ? Colors.red : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              onPressed: () {
                if (isWatched) {
                  service.removeFromWatchlist(widget.listing.id);
                } else {
                  service.addToWatchlist(widget.listing.id);
                }
              },
            );
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: Icon(
              Icons.share_rounded,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
          onPressed: () {
            // TODO: Implement share
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                typeColor.withOpacity(0.2),
                typeColor.withOpacity(0.05),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Hero(
            tag: 'pokemon_${widget.listing.id}',
            child: Image.network(
              widget.listing.pokemon.imageUrl,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => Icon(
                    Icons.catching_pokemon,
                    size: 120,
                    color: typeColor.withOpacity(0.3),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonInfo() {
    final typeColor = _getTypeColor(widget.listing.pokemon.type);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.listing.pokemon.type,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (widget.listing.listingType == ListingType.auction)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade600, Colors.purple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gavel, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'AUCTION',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_rounded,
                      color: Colors.grey.shade500,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.listing.viewCount}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.favorite, color: Colors.red.shade300, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.listing.favoriteCount}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.listing.pokemon.name,
            style: GoogleFonts.poppins(
              color: const Color(0xFF303943),
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Token ID: #${widget.listing.pokemon.tokenId}',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final isPositive = widget.listing.priceChange24h >= 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                    widget.listing.listingType == ListingType.auction
                        ? 'Current Bid'
                        : 'Price',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('⟠', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      Text(
                        widget.listing.listingType == ListingType.auction
                            ? (widget.listing.currentBid ??
                                    widget.listing.minimumBid ??
                                    0)
                                .toStringAsFixed(4)
                            : widget.listing.priceInEth.toStringAsFixed(4),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF303943),
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'ETH',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '≈ \$${widget.listing.priceInUsd.toStringAsFixed(2)} USD',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color:
                          isPositive
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isPositive ? '+' : ''}${widget.listing.priceChange24h.toStringAsFixed(2)}%',
                      style: GoogleFonts.poppins(
                        color:
                            isPositive
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.listing.listingType == ListingType.auction) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAuctionInfo(
                    'Minimum Bid',
                    '${(widget.listing.minimumBid ?? 0).toStringAsFixed(4)} ETH',
                    Icons.gavel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAuctionInfo(
                    'Total Bids',
                    '${widget.listing.bids.length}',
                    Icons.people,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAuctionInfo(
                    'Ends In',
                    _getTimeRemaining(widget.listing.expiresAt),
                    Icons.timer,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuctionInfo(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.purple.shade600, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF303943),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChart() {
    if (widget.listing.priceHistory.prices.isEmpty)
      return const SizedBox.shrink();

    final isPositive = widget.listing.priceChange24h >= 0;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price History',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF303943),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  _buildTimeFilterChip('24H', true),
                  _buildTimeFilterChip('7D', false),
                  _buildTimeFilterChip('30D', false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _PriceChartPainter(
                prices: widget.listing.priceHistory.prices,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFCD3131).withOpacity(0.1)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFCD3131) : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? const Color(0xFFCD3131) : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    final stats = widget.listing.pokemon.stats;
    final typeColor = _getTypeColor(widget.listing.pokemon.type);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats',
            style: GoogleFonts.poppins(
              color: const Color(0xFF303943),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...stats.entries.map(
            (entry) => _buildStatBar(entry.key, entry.value, typeColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBattleRecord(
                'Battles Won',
                widget.listing.pokemon.battlesWon,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildBattleRecord(
                'Battles Lost',
                widget.listing.pokemon.battlesLost,
                Colors.red,
              ),
              const SizedBox(width: 12),
              _buildBattleRecord(
                'XP',
                widget.listing.pokemon.xp,
                const Color(0xFFFFD700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String name, int value, Color typeColor) {
    final maxValue = 150.0;
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              name.toUpperCase(),
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getStatColor(percentage),
                          _getStatColor(percentage).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: _getStatColor(percentage).withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              style: GoogleFonts.poppins(
                color: const Color(0xFF303943),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatColor(double percentage) {
    if (percentage > 0.7) return Colors.green;
    if (percentage > 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildBattleRecord(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final typeColor = _getTypeColor(widget.listing.pokemon.type);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: GoogleFonts.poppins(
              color: const Color(0xFF303943),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: typeColor.withOpacity(0.1)),
            ),
            child: Text(
              'A rare ${widget.listing.pokemon.type}-type Pokémon with exceptional stats. '
              'This NFT is part of the PokeAgent collection, featuring unique blockchain-verified Pokémon. '
              'Evolution stage: ${widget.listing.pokemon.evolutionStage}/3',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
                height: 1.6,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidHistory() {
    if (widget.listing.bids.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bid History',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF303943),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.listing.bids.length} bids',
                  style: GoogleFonts.poppins(
                    color: Colors.purple.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.listing.bids.take(5).map((bid) => _buildBidItem(bid)),
        ],
      ),
    );
  }

  Widget _buildBidItem(Bid bid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.purple.shade500],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bid.bidderName,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF303943),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatTime(bid.timestamp),
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Text('⟠ ', style: TextStyle(fontSize: 13)),
                  Text(
                    bid.amount.toStringAsFixed(4),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF303943),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                'ETH',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seller',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.listing.sellerName,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF303943),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.listing.sellerAddress,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified, color: Colors.blue.shade600, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.listing.listingType == ListingType.auction
                        ? 'Current Bid'
                        : 'Price',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      const Text('⟠ ', style: TextStyle(fontSize: 18)),
                      Text(
                        widget.listing.listingType == ListingType.auction
                            ? (widget.listing.currentBid ??
                                    widget.listing.minimumBid ??
                                    0)
                                .toStringAsFixed(4)
                            : widget.listing.priceInEth.toStringAsFixed(4),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF303943),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child:
                  widget.listing.listingType == ListingType.auction
                      ? ElevatedButton(
                        onPressed: _showBidDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Place Bid',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      )
                      : ElevatedButton(
                        onPressed: _buyNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCD3131),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Buy Now',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBidDialog() {
    final controller = TextEditingController();
    final minBid =
        (widget.listing.currentBid ?? widget.listing.minimumBid ?? 0) + 0.001;
    controller.text = minBid.toStringAsFixed(4);
    final typeColor = _getTypeColor(widget.listing.pokemon.type);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(widget.listing.pokemon.imageUrl),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Place Bid on ${widget.listing.pokemon.name}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF303943),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Current bid: ${(widget.listing.currentBid ?? 0).toStringAsFixed(4)} ETH',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF303943),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Your Bid (ETH)',
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixText: '⟠ ',
                    prefixStyle: const TextStyle(fontSize: 24),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.purple.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Minimum bid: ${minBid.toStringAsFixed(4)} ETH',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(controller.text) ?? 0;
                      if (amount >= minBid) {
                        final tradingService = context.read<TradingService>();
                        await tradingService.placeBid(
                          listingId: widget.listing.id,
                          amount: amount,
                          bidderAddress: '0xYourWallet',
                          bidderName: 'You',
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Bid placed successfully!',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Confirm Bid',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
    );
  }

  void _buyNow() {
    final typeColor = _getTypeColor(widget.listing.pokemon.type);
    // Capture references before showing dialog to avoid deactivated widget issues
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final tradingService = context.read<TradingService>();
    final walletService = context.read<WalletService>();
    final priceInEth = widget.listing.priceInEth;
    final listingId = widget.listing.id;
    final pokemonName = widget.listing.pokemon.name;
    final purchasedPokemon = widget.listing.pokemon;

    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Purchase',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF303943),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You are about to purchase:',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Image.network(widget.listing.pokemon.imageUrl),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.listing.pokemon.name,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF303943),
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('⟠ ', style: TextStyle(fontSize: 14)),
                              Text(
                                widget.listing.priceInEth.toStringAsFixed(4),
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF303943),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                ' ETH',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This action will require a wallet signature',
                            style: GoogleFonts.poppins(
                              color: Colors.orange.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Close confirmation dialog
                            Navigator.pop(dialogContext);

                            // Check wallet connection first
                            if (!walletService.isConnected) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please connect your wallet first',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }

                            // Check balance
                            if (walletService.cryptoBalance < priceInEth) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Insufficient balance. You need ${priceInEth.toStringAsFixed(4)} ETH',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }

                            // Check if already owned
                            final alreadyOwned = await _checkIfAlreadyOwned(
                              pokemonName,
                            );
                            if (alreadyOwned) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You already own $pokemonName!',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }

                            // Show realistic payment flow dialog
                            await _showPaymentFlow(
                              rootNavigator: rootNavigator,
                              scaffoldMessenger: scaffoldMessenger,
                              tradingService: tradingService,
                              walletService: walletService,
                              priceInEth: priceInEth,
                              listingId: listingId,
                              pokemonName: pokemonName,
                              pokemon: purchasedPokemon,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCD3131),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Color _getTypeColor(String type) {
    return _typeColors[type] ?? const Color(0xFFCD3131);
  }

  String _getTimeRemaining(DateTime? expiresAt) {
    if (expiresAt == null) return 'No expiry';
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inDays > 0) return '${remaining.inDays}d';
    if (remaining.inHours > 0) return '${remaining.inHours}h';
    return '${remaining.inMinutes}m';
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Shows a realistic multi-step payment flow dialog
  Future<void> _showPaymentFlow({
    required NavigatorState rootNavigator,
    required ScaffoldMessengerState scaffoldMessenger,
    required TradingService tradingService,
    required WalletService walletService,
    required double priceInEth,
    required String listingId,
    required String pokemonName,
    required PokeAgent pokemon,
  }) async {
    int currentStep = 0;
    bool isProcessing = true;
    String statusMessage = 'Initializing transaction...';
    bool transactionSuccess = false;
    String? transactionHash;
    final typeColor = _getTypeColor(pokemon.type);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Process steps automatically
            Future<void> processTransaction() async {
              // Step 1: Preparing transaction
              setDialogState(() {
                currentStep = 0;
                statusMessage = 'Preparing transaction...';
              });
              await Future.delayed(const Duration(milliseconds: 800));

              // Step 2: Wallet signature request
              setDialogState(() {
                currentStep = 1;
                statusMessage = 'Requesting wallet signature...';
              });
              await Future.delayed(const Duration(seconds: 1));

              // Step 3: Processing payment
              setDialogState(() {
                currentStep = 2;
                statusMessage = 'Processing payment...';
              });

              // Actually process the purchase
              final result = await tradingService.buyListing(
                listingId: listingId,
                buyerAddress: walletService.walletAddress ?? '',
              );

              if (result != null) {
                // Step 4: Confirming on blockchain
                setDialogState(() {
                  currentStep = 3;
                  statusMessage = 'Confirming on blockchain...';
                });
                await Future.delayed(const Duration(milliseconds: 800));

                // Generate fake transaction hash
                transactionHash =
                    '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}${'a' * 40}';

                // Step 5: Transferring NFT
                setDialogState(() {
                  currentStep = 4;
                  statusMessage = 'Transferring NFT to your wallet...';
                });
                await Future.delayed(const Duration(milliseconds: 600));

                // Deduct wallet balance
                await walletService.deductTokens(priceInEth);

                // Save Pokemon to home screen
                await _savePokemonToHomeScreen(pokemon);

                // Update user stats
                try {
                  final statsService = context.read<UserStatsService>();
                  await statsService.addPokemon();
                } catch (e) {
                  debugPrint('Could not update stats: $e');
                }

                transactionSuccess = true;
                setDialogState(() {
                  isProcessing = false;
                  statusMessage = 'Transaction complete!';
                });
              } else {
                setDialogState(() {
                  isProcessing = false;
                  transactionSuccess = false;
                  statusMessage = 'Transaction failed';
                });
              }
            }

            // Start processing on first build
            if (currentStep == 0 && isProcessing) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                processTransaction();
              });
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top gradient header with Pokemon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            typeColor.withOpacity(0.15),
                            typeColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Status icon with animation
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  isProcessing
                                      ? Colors.white
                                      : transactionSuccess
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isProcessing
                                          ? typeColor
                                          : transactionSuccess
                                          ? Colors.green
                                          : Colors.red)
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child:
                                isProcessing
                                    ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: typeColor,
                                            backgroundColor: typeColor
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                        Image.network(
                                          pokemon.imageUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    )
                                    : Icon(
                                      transactionSuccess
                                          ? Icons.check_circle_rounded
                                          : Icons.error_rounded,
                                      color:
                                          transactionSuccess
                                              ? Colors.green
                                              : Colors.red,
                                      size: 50,
                                    ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Text(
                            isProcessing
                                ? 'Processing Purchase'
                                : transactionSuccess
                                ? '🎉 Purchase Complete!'
                                : 'Purchase Failed',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF303943),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusMessage,
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Pokemon info card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.network(
                                    pokemon.imageUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pokemonName,
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF303943),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: typeColor,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              pokemon.type,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          walletService.cryptoIcon,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          priceInEth.toStringAsFixed(4),
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF303943),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      walletService.cryptoSymbol,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Transaction steps with better design
                          ...List.generate(5, (index) {
                            final steps = [
                              {
                                'icon': Icons.receipt_long_rounded,
                                'text': 'Prepare transaction',
                              },
                              {
                                'icon': Icons.fingerprint_rounded,
                                'text': 'Wallet signature',
                              },
                              {
                                'icon': Icons.payment_rounded,
                                'text': 'Process payment',
                              },
                              {
                                'icon': Icons.link_rounded,
                                'text': 'Blockchain confirmation',
                              },
                              {
                                'icon': Icons.swap_horiz_rounded,
                                'text': 'Transfer NFT',
                              },
                            ];
                            final isComplete = index < currentStep;
                            final isCurrent =
                                index == currentStep && isProcessing;
                            final isPending = index > currentStep;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isComplete
                                        ? Colors.green.shade50
                                        : isCurrent
                                        ? typeColor.withOpacity(0.1)
                                        : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isComplete
                                          ? Colors.green.shade200
                                          : isCurrent
                                          ? typeColor.withOpacity(0.3)
                                          : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient:
                                          isComplete
                                              ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF4CAF50),
                                                  Color(0xFF66BB6A),
                                                ],
                                              )
                                              : isCurrent
                                              ? LinearGradient(
                                                colors: [
                                                  typeColor,
                                                  typeColor.withOpacity(0.8),
                                                ],
                                              )
                                              : null,
                                      color:
                                          isPending
                                              ? Colors.grey.shade200
                                              : null,
                                      shape: BoxShape.circle,
                                    ),
                                    child:
                                        isComplete
                                            ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            )
                                            : isCurrent
                                            ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : Icon(
                                              steps[index]['icon'] as IconData,
                                              color: Colors.grey.shade400,
                                              size: 16,
                                            ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      steps[index]['text'] as String,
                                      style: GoogleFonts.poppins(
                                        color:
                                            isPending
                                                ? Colors.grey.shade400
                                                : const Color(0xFF303943),
                                        fontSize: 13,
                                        fontWeight:
                                            isComplete || isCurrent
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (isComplete)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade400,
                                      size: 18,
                                    ),
                                ],
                              ),
                            );
                          }),

                          // Transaction details (show when complete)
                          if (!isProcessing && transactionSuccess) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green.shade50,
                                    Colors.green.shade50.withOpacity(0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildTransactionRow(
                                    'Amount Paid',
                                    '${walletService.cryptoIcon} ${priceInEth.toStringAsFixed(4)} ${walletService.cryptoSymbol}',
                                    Colors.green.shade700,
                                  ),
                                  const Divider(height: 20),
                                  _buildTransactionRow(
                                    'New Balance',
                                    '${walletService.cryptoIcon} ${walletService.formattedCryptoBalance} ${walletService.cryptoSymbol}',
                                    const Color(0xFF303943),
                                  ),
                                  if (transactionHash != null) ...[
                                    const Divider(height: 20),
                                    _buildTransactionRow(
                                      'Tx Hash',
                                      '${transactionHash!.substring(0, 10)}...${transactionHash!.substring(transactionHash!.length - 6)}',
                                      Colors.blue.shade600,
                                      isHash: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Action button
                          if (!isProcessing)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  if (transactionSuccess) {
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.celebration,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Purchase Successful!',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$pokemonName added to your collection',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.green.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        duration: const Duration(seconds: 4),
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                    rootNavigator.pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      transactionSuccess
                                          ? Colors.green.shade600
                                          : const Color(0xFFCD3131),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      transactionSuccess
                                          ? Icons.home_rounded
                                          : Icons.close_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      transactionSuccess
                                          ? 'Go to Collection'
                                          : 'Close',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionRow(
    String label,
    String value,
    Color valueColor, {
    bool isHash = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: valueColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (isHash) ...[
              const SizedBox(width: 6),
              Icon(Icons.open_in_new, size: 14, color: Colors.blue.shade600),
            ],
          ],
        ),
      ],
    );
  }

  /// Saves the purchased Pokemon to the home screen collection
  Future<void> _savePokemonToHomeScreen(PokeAgent pokemon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agentsJson = prefs.getStringList('agents') ?? [];

      // Check if Pokemon already exists by name (to prevent duplicates)
      final existingAgents =
          agentsJson
              .map((json) => PokeAgent.fromJson(jsonDecode(json)))
              .toList();

      // Check by name to prevent buying same Pokemon multiple times
      final alreadyExists = existingAgents.any(
        (a) => a.name.toLowerCase() == pokemon.name.toLowerCase(),
      );

      if (!alreadyExists) {
        // Create a new agent with unique ID
        final newAgent = PokeAgent(
          id:
              'purchased_${pokemon.name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
          name: pokemon.name,
          type: pokemon.type,
          imageUrl: pokemon.imageUrl,
          xp: pokemon.xp,
          evolutionStage: pokemon.evolutionStage,
          personality: pokemon.personality,
          stats: pokemon.stats,
          tokenId: pokemon.tokenId,
          contractAddress: pokemon.contractAddress,
          isFavorite: false,
        );

        agentsJson.add(jsonEncode(newAgent.toJson()));
        await prefs.setStringList('agents', agentsJson);
        debugPrint('✅ Pokemon saved to home screen: ${pokemon.name}');
      } else {
        debugPrint('⚠️ Pokemon ${pokemon.name} already exists in collection');
      }
    } catch (e) {
      debugPrint('Error saving Pokemon to home screen: $e');
    }
  }

  /// Checks if a Pokemon with the same name is already owned
  Future<bool> _checkIfAlreadyOwned(String pokemonName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agentsJson = prefs.getStringList('agents') ?? [];

      final existingAgents =
          agentsJson
              .map((json) => PokeAgent.fromJson(jsonDecode(json)))
              .toList();

      return existingAgents.any(
        (a) => a.name.toLowerCase() == pokemonName.toLowerCase(),
      );
    } catch (e) {
      debugPrint('Error checking ownership: $e');
      return false;
    }
  }
}

class _PriceChartPainter extends CustomPainter {
  final List<PricePoint> prices;
  final Color color;

  _PriceChartPainter({required this.prices, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final minPrice = prices.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < prices.length; i++) {
      final x = (i / (prices.length - 1)) * size.width;
      final y =
          priceRange == 0
              ? size.height / 2
              : size.height -
                  ((prices[i].price - minPrice) / priceRange * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill
    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Draw dots at end
    final dotPaint = Paint()..color = color;
    final lastX = size.width;
    final lastY =
        priceRange == 0
            ? size.height / 2
            : size.height -
                ((prices.last.price - minPrice) / priceRange * size.height);
    canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
