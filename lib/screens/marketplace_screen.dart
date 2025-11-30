import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../services/trading_service.dart';
import '../models/trading_models.dart';
import 'nft_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedType = 'All';
  String _sortBy = 'recent';
  bool _sortAscending = false;
  RangeValues _priceRange = const RangeValues(0, 1);

  final List<String> _types = [
    'All',
    'Fire',
    'Water',
    'Grass',
    'Electric',
    'Psychic',
    'Ghost',
    'Dragon',
    'Ice',
    'Fighting',
    'Normal',
  ];

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
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCryptoPrices(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMarketplaceGrid(),
                  _buildTrendingList(),
                  _buildAuctionsList(),
                  _buildWatchlist(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<TradingService>(
      builder: (context, tradingService, _) {
        final stats = tradingService.marketStats;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade100,
                                Colors.grey.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.grey.shade700,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NFT Marketplace',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF303943),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Live Trading',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildHeaderIconButton(
                        Icons.filter_list_rounded,
                        _showFilterDialog,
                      ),
                      const SizedBox(width: 10),
                      _buildHeaderIconButton(Icons.search_rounded, () {
                        // TODO: Implement search
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (stats != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatChip(
                        'Floor',
                        '${tradingService.floorPrice.toStringAsFixed(4)} ETH',
                        Icons.trending_down_rounded,
                      ),
                      const SizedBox(width: 10),
                      _buildStatChip(
                        'Volume 24h',
                        '${stats.totalVolume24h.toStringAsFixed(2)} ETH',
                        Icons.bar_chart_rounded,
                      ),
                      const SizedBox(width: 10),
                      _buildStatChip(
                        'Listed',
                        '${stats.totalListings}',
                        Icons.local_offer_rounded,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF303943), size: 22),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFCD3131).withOpacity(0.1),
            const Color(0xFFCD3131).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCD3131).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCD3131).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFCD3131).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFCD3131), size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF303943),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoPrices() {
    return Consumer<TradingService>(
      builder: (context, tradingService, _) {
        final prices = tradingService.cryptoPrices;
        return Container(
          height: 90,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children:
                prices.entries.map((entry) {
                  return _buildPriceCard(entry.value);
                }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPriceCard(CryptoPrice price) {
    final isPositive = price.change24h >= 0;
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPositive ? Colors.green.shade200 : Colors.red.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? Colors.green : Colors.red).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              _getCryptoIcon(price.symbol),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  price.symbol,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF303943),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            '\$${price.priceUsd.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF303943),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 10,
              ),
              Flexible(
                child: Text(
                  '${isPositive ? '+' : ''}${price.change24h.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    color:
                        isPositive
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getCryptoIcon(String symbol) {
    final icons = {'ETH': '⟠', 'BTC': '₿', 'SOL': '◎', 'XLM': '✦'};
    return Text(
      icons[symbol] ?? '●',
      style: const TextStyle(fontSize: 14, height: 1.0),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFCD3131), Color(0xFFE04545)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCD3131).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(14),
        tabs: [
          _buildTabItem('Market', Icons.storefront_rounded, 0),
          _buildTabItem('Trending', Icons.local_fire_department_rounded, 1),
          _buildTabItem('Auctions', Icons.gavel_rounded, 2),
          _buildTabItem('Watchlist', Icons.favorite_rounded, 3),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, IconData icon, int index) {
    return Tab(
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final isSelected = _tabController.index == index;
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Icon(icon, size: 14),
                const SizedBox(width: 4),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMarketplaceGrid() {
    return Consumer<TradingService>(
      builder: (context, tradingService, _) {
        final listings = tradingService.filterListings(
          type: _selectedType == 'All' ? null : _selectedType,
          sortBy: _sortBy,
          ascending: _sortAscending,
        );

        return Column(
          children: [
            _buildTypeFilter(),
            _buildSortOptions(),
            Expanded(
              child:
                  listings.isEmpty
                      ? _buildEmptyState('No listings found')
                      : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 50),
                            child: _buildListingCard(listings[index]),
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypeFilter() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          final isSelected = _selectedType == type;
          final color = _typeColors[type] ?? const Color(0xFFCD3131);
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Text(
                type,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    return _typeColors[type] ?? const Color(0xFFCD3131);
  }

  Widget _buildSortOptions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          _buildSortChip('Recent', 'recent'),
          _buildSortChip('Price', 'price'),
          _buildSortChip('Popular', 'popular'),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _sortAscending = !_sortAscending),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: const Color(0xFFCD3131),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFCD3131).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFCD3131) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? const Color(0xFFCD3131) : Colors.grey.shade600,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(NFTListing listing) {
    final isPositiveChange = listing.priceChange24h >= 0;
    final typeColor = _getTypeColor(listing.pokemon.type);

    return GestureDetector(
      onTap: () => _navigateToDetail(listing),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with gradient background
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          typeColor.withOpacity(0.2),
                          typeColor.withOpacity(0.08),
                          Colors.white,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Hero(
                      tag: 'pokemon_${listing.id}',
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.network(
                          listing.pokemon.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) => Icon(
                                Icons.catching_pokemon,
                                size: 60,
                                color: typeColor.withOpacity(0.3),
                              ),
                        ),
                      ),
                    ),
                  ),
                  // Type badge with glow
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [typeColor, typeColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: typeColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        listing.pokemon.type,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Watchlist heart button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Consumer<TradingService>(
                      builder: (context, service, _) {
                        final isWatched = service.isInWatchlist(listing.id);
                        return GestureDetector(
                          onTap: () {
                            if (isWatched) {
                              service.removeFromWatchlist(listing.id);
                            } else {
                              service.addToWatchlist(listing.id);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              isWatched
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color:
                                  isWatched
                                      ? const Color(0xFFCD3131)
                                      : Colors.grey.shade400,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Auction badge
                  if (listing.listingType == ListingType.auction)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade600,
                              Colors.purple.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.gavel_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AUCTION',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Divider line
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    typeColor.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.pokemon.name,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF303943),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'by ${listing.sellerName}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '⟠',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                listing.priceInEth.toStringAsFixed(4),
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF303943),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isPositiveChange
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPositiveChange
                                        ? Icons.trending_up_rounded
                                        : Icons.trending_down_rounded,
                                    color:
                                        isPositiveChange
                                            ? Colors.green.shade600
                                            : Colors.red.shade600,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${isPositiveChange ? '+' : ''}${listing.priceChange24h.toStringAsFixed(1)}%',
                                    style: GoogleFonts.poppins(
                                      color:
                                          isPositiveChange
                                              ? Colors.green.shade600
                                              : Colors.red.shade600,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${listing.priceInUsd.toStringAsFixed(2)} USD',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingList() {
    return Consumer<TradingService>(
      builder: (context, tradingService, _) {
        final trending = tradingService.trendingListings;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trending.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildTrendingCard(trending[index], index + 1),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendingCard(NFTListing listing, int rank) {
    final typeColor = _getTypeColor(listing.pokemon.type);

    // Rank medal colors
    Color getRankColor() {
      switch (rank) {
        case 1:
          return const Color(0xFFFFD700); // Gold
        case 2:
          return const Color(0xFFC0C0C0); // Silver
        case 3:
          return const Color(0xFFCD7F32); // Bronze
        default:
          return Colors.grey.shade400;
      }
    }

    IconData getRankIcon() {
      switch (rank) {
        case 1:
          return Icons.emoji_events_rounded;
        case 2:
          return Icons.military_tech_rounded;
        case 3:
          return Icons.workspace_premium_rounded;
        default:
          return Icons.tag_rounded;
      }
    }

    return GestureDetector(
      onTap: () => _navigateToDetail(listing),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  rank <= 3
                      ? getRankColor().withOpacity(0.2)
                      : Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: rank <= 3 ? 2 : 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient accent for top 3
            if (rank <= 3)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [getRankColor(), getRankColor().withOpacity(0.5)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Rank medal
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient:
                          rank <= 3
                              ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  getRankColor(),
                                  getRankColor().withOpacity(0.7),
                                ],
                              )
                              : null,
                      color: rank > 3 ? Colors.grey.shade100 : null,
                      shape: BoxShape.circle,
                      boxShadow:
                          rank <= 3
                              ? [
                                BoxShadow(
                                  color: getRankColor().withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          getRankIcon(),
                          color:
                              rank <= 3 ? Colors.white : Colors.grey.shade500,
                          size: rank <= 3 ? 24 : 20,
                        ),
                        if (rank > 3)
                          Positioned(
                            bottom: 6,
                            child: Text(
                              '$rank',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Pokemon image with gradient background
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          typeColor.withOpacity(0.25),
                          typeColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: typeColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        listing.pokemon.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                listing.pokemon.name,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF303943),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (rank <= 3) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                color: getRankColor(),
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    typeColor.withOpacity(0.2),
                                    typeColor.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                listing.pokemon.type,
                                style: GoogleFonts.poppins(
                                  color: typeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Floor Price',
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
                  // Price info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '⟠',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            listing.priceInEth.toStringAsFixed(4),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF303943),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.withOpacity(0.15),
                              Colors.green.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: Colors.green.shade600,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${listing.priceChange24h.toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuctionsList() {
    return Consumer<TradingService>(
      builder: (context, tradingService, _) {
        final auctions = tradingService.filterListings(
          listingType: ListingType.auction,
        );

        if (auctions.isEmpty) {
          return _buildEmptyState('No active auctions');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: auctions.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildAuctionCard(auctions[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildAuctionCard(NFTListing listing) {
    final typeColor = _getTypeColor(listing.pokemon.type);
    return GestureDetector(
      onTap: () => _navigateToDetail(listing),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with gradient and timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade600,
                    Colors.purple.shade400,
                    Colors.deepPurple.shade400,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.gavel_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIVE AUCTION',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ends soon!',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red.shade500,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.timer_outlined,
                          color: Colors.purple.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getTimeRemaining(listing.expiresAt),
                          style: GoogleFonts.poppins(
                            color: Colors.purple.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Pokemon image with gradient
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          typeColor.withOpacity(0.25),
                          typeColor.withOpacity(0.08),
                          Colors.white,
                        ],
                        radius: 0.9,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: typeColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.network(
                            listing.pokemon.imageUrl,
                            fit: BoxFit.contain,
                            width: 80,
                            height: 80,
                          ),
                        ),
                        // Type badge
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [typeColor, typeColor.withOpacity(0.8)],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(18),
                              ),
                            ),
                            child: Text(
                              listing.pokemon.type,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.pokemon.name,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF303943),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              listing.sellerName,
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAuctionPriceEnhanced(
                                'Current Bid',
                                listing.currentBid ?? listing.minimumBid ?? 0,
                                Colors.purple,
                                true,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade200,
                            ),
                            Expanded(
                              child: _buildAuctionPriceEnhanced(
                                'Min Bid',
                                listing.minimumBid ?? 0,
                                Colors.grey,
                                false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bid button with gradient
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade600,
                      Colors.deepPurple.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _showBidDialog(listing),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.gavel_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Place Your Bid',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuctionPriceEnhanced(
    String label,
    double price,
    Color color,
    bool isHighlighted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color:
                      isHighlighted
                          ? color.withOpacity(0.1)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('⟠', style: TextStyle(fontSize: 10)),
              ),
              const SizedBox(width: 4),
              Text(
                price.toStringAsFixed(4),
                style: GoogleFonts.poppins(
                  color:
                      isHighlighted
                          ? Color.alphaBlend(Colors.black26, color)
                          : const Color(0xFF303943),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlist() {
    return Consumer<TradingService>(
      builder: (context, tradingService, _) {
        final watchlist = tradingService.watchlistListings;

        if (watchlist.isEmpty) {
          return _buildEmptyState('Your watchlist is empty');
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: watchlist.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: index * 50),
              child: _buildListingCard(watchlist[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFCD3131).withOpacity(0.1),
                    const Color(0xFFCD3131).withOpacity(0.03),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCD3131).withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.catching_pokemon,
                  size: 48,
                  color: const Color(0xFFCD3131).withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: const Color(0xFF303943),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Check back later for updates',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade100, Colors.grey.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore_rounded,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Explore Marketplace',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeRemaining(DateTime? expiresAt) {
    if (expiresAt == null) return 'No expiry';
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inDays > 0) return '${remaining.inDays}d left';
    if (remaining.inHours > 0) return '${remaining.inHours}h left';
    return '${remaining.inMinutes}m left';
  }

  void _navigateToDetail(NFTListing listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NFTDetailScreen(listing: listing),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
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
                      Text(
                        'Filter Listings',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF303943),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Price Range (ETH)',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_priceRange.start.toStringAsFixed(2)} ETH',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFCD3131),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${_priceRange.end.toStringAsFixed(2)} ETH',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFCD3131),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFFCD3131),
                          inactiveTrackColor: Colors.grey.shade200,
                          thumbColor: const Color(0xFFCD3131),
                          overlayColor: const Color(
                            0xFFCD3131,
                          ).withOpacity(0.2),
                        ),
                        child: RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 1,
                          divisions: 20,
                          labels: RangeLabels(
                            _priceRange.start.toStringAsFixed(2),
                            _priceRange.end.toStringAsFixed(2),
                          ),
                          onChanged: (values) {
                            setModalState(() => _priceRange = values);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCD3131),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Apply Filters',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showBidDialog(NFTListing listing) {
    final controller = TextEditingController();
    final minBid = (listing.currentBid ?? listing.minimumBid ?? 0) + 0.001;
    controller.text = minBid.toStringAsFixed(4);
    final typeColor = _getTypeColor(listing.pokemon.type);

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
                      child: Image.network(listing.pokemon.imageUrl),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bid on ${listing.pokemon.name}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF303943),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Current bid: ${(listing.currentBid ?? 0).toStringAsFixed(4)} ETH',
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
                      borderSide: const BorderSide(
                        color: Colors.purple,
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
                      if (amount > minBid) {
                        final tradingService = context.read<TradingService>();
                        await tradingService.placeBid(
                          listingId: listing.id,
                          amount: amount,
                          bidderAddress: '0xYourWallet',
                          bidderName: 'You',
                        );
                        if (mounted) Navigator.pop(context);
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
                      'Place Bid',
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
}
