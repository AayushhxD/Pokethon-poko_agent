import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokeagent.dart';
import '../models/trading_models.dart';

/// Service for NFT trading marketplace with real-time crypto prices
class TradingService extends ChangeNotifier {
  final SharedPreferences _prefs;

  List<NFTListing> _listings = [];
  List<TradeRecord> _tradeHistory = [];
  Map<String, CryptoPrice> _cryptoPrices = {};
  MarketStats? _marketStats;
  bool _isLoading = false;
  String? _error;

  // Watchlist
  final Set<String> _watchlist = {};

  TradingService(this._prefs) {
    _loadData();
    _initializeMockData();
    _startPriceUpdates();
  }

  // Getters
  List<NFTListing> get listings => _listings;
  List<NFTListing> get activeListings =>
      _listings.where((l) => l.status == ListingStatus.active).toList();
  List<TradeRecord> get tradeHistory => _tradeHistory;
  Map<String, CryptoPrice> get cryptoPrices => _cryptoPrices;
  MarketStats? get marketStats => _marketStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get watchlist => _watchlist;

  CryptoPrice? get ethPrice => _cryptoPrices['ETH'];
  CryptoPrice? get btcPrice => _cryptoPrices['BTC'];

  // Get floor price (lowest active listing)
  double get floorPrice {
    final active = activeListings;
    if (active.isEmpty) return 0.0;
    return active.map((l) => l.priceInEth).reduce(math.min);
  }

  // Load persisted data
  Future<void> _loadData() async {
    final watchlistJson = _prefs.getStringList('trading_watchlist') ?? [];
    _watchlist.addAll(watchlistJson);

    final historyJson = _prefs.getString('trade_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _tradeHistory = decoded.map((j) => TradeRecord.fromJson(j)).toList();
    }
    notifyListeners();
  }

  // Save data
  Future<void> _saveData() async {
    await _prefs.setStringList('trading_watchlist', _watchlist.toList());
    await _prefs.setString(
      'trade_history',
      jsonEncode(_tradeHistory.map((t) => t.toJson()).toList()),
    );
  }

  // Initialize mock data for demo
  void _initializeMockData() {
    // Mock crypto prices
    _cryptoPrices = {
      'ETH': CryptoPrice.mock('ETH'),
      'BTC': CryptoPrice.mock('BTC'),
      'SOL': CryptoPrice.mock('SOL'),
      'XLM': CryptoPrice.mock('XLM'),
    };

    // Mock market stats
    _marketStats = MarketStats.mock();

    // Mock listings
    _listings = _generateMockListings();
    notifyListeners();
  }

  List<NFTListing> _generateMockListings() {
    final random = math.Random();
    final pokemonData = [
      {
        'name': 'Charizard',
        'type': 'Fire',
        'rarity': 'Legendary',
        'basePrice': 0.15,
      },
      {
        'name': 'Blastoise',
        'type': 'Water',
        'rarity': 'Rare',
        'basePrice': 0.08,
      },
      {
        'name': 'Venusaur',
        'type': 'Grass',
        'rarity': 'Rare',
        'basePrice': 0.07,
      },
      {
        'name': 'Pikachu',
        'type': 'Electric',
        'rarity': 'Common',
        'basePrice': 0.025,
      },
      {
        'name': 'Mewtwo',
        'type': 'Psychic',
        'rarity': 'Mythical',
        'basePrice': 0.35,
      },
      {'name': 'Gengar', 'type': 'Ghost', 'rarity': 'Rare', 'basePrice': 0.065},
      {
        'name': 'Dragonite',
        'type': 'Dragon',
        'rarity': 'Legendary',
        'basePrice': 0.12,
      },
      {
        'name': 'Gyarados',
        'type': 'Water',
        'rarity': 'Rare',
        'basePrice': 0.055,
      },
      {
        'name': 'Alakazam',
        'type': 'Psychic',
        'rarity': 'Rare',
        'basePrice': 0.045,
      },
      {
        'name': 'Machamp',
        'type': 'Fighting',
        'rarity': 'Rare',
        'basePrice': 0.04,
      },
      {
        'name': 'Articuno',
        'type': 'Ice',
        'rarity': 'Legendary',
        'basePrice': 0.18,
      },
      {
        'name': 'Zapdos',
        'type': 'Electric',
        'rarity': 'Legendary',
        'basePrice': 0.17,
      },
      {
        'name': 'Moltres',
        'type': 'Fire',
        'rarity': 'Legendary',
        'basePrice': 0.16,
      },
      {
        'name': 'Eevee',
        'type': 'Normal',
        'rarity': 'Common',
        'basePrice': 0.02,
      },
      {
        'name': 'Snorlax',
        'type': 'Normal',
        'rarity': 'Rare',
        'basePrice': 0.05,
      },
    ];

    final sellers = [
      {'address': '0x1234...5678', 'name': 'CryptoTrainer'},
      {'address': '0xabcd...efgh', 'name': 'PokeMaster'},
      {'address': '0x9876...5432', 'name': 'NFTCollector'},
      {'address': '0xdead...beef', 'name': 'BlockchainPro'},
      {'address': '0xcafe...babe', 'name': 'Web3Gamer'},
    ];

    return pokemonData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final seller = sellers[random.nextInt(sellers.length)];

      // Price variation based on market conditions
      final priceVariation = 0.8 + random.nextDouble() * 0.4; // 80% - 120%
      final priceInEth = (data['basePrice'] as double) * priceVariation;
      final ethUsdPrice = _cryptoPrices['ETH']?.priceUsd ?? 3245.67;

      // Generate price history
      final priceHistory = PriceHistory(
        prices: List.generate(24, (i) {
          final historicalVariation = 0.9 + random.nextDouble() * 0.2;
          return PricePoint(
            price: priceInEth * historicalVariation,
            timestamp: DateTime.now().subtract(Duration(hours: 24 - i)),
          );
        }),
      );

      final isAuction = random.nextBool() && index % 3 == 0;

      return NFTListing(
        id: 'listing_$index',
        pokemon: PokeAgent(
          id: 'poke_$index',
          name: data['name'] as String,
          type: data['type'] as String,
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${_getPokemonId(data['name'] as String)}.png',
          xp: random.nextInt(500),
          evolutionStage: random.nextInt(3) + 1,
          stats: {
            'hp': 80 + random.nextInt(50),
            'attack': 60 + random.nextInt(50),
            'defense': 50 + random.nextInt(50),
            'speed': 70 + random.nextInt(50),
            'special': 65 + random.nextInt(50),
          },
          battlesWon: random.nextInt(50),
          battlesLost: random.nextInt(20),
          tokenId: '${1000 + index}',
        ),
        sellerAddress: seller['address'] as String,
        sellerName: seller['name'] as String,
        priceInEth: priceInEth,
        priceInUsd: priceInEth * ethUsdPrice,
        listedAt: DateTime.now().subtract(Duration(hours: random.nextInt(168))),
        listingType: isAuction ? ListingType.auction : ListingType.fixedPrice,
        minimumBid: isAuction ? priceInEth * 0.5 : null,
        currentBid:
            isAuction ? priceInEth * (0.6 + random.nextDouble() * 0.3) : null,
        priceHistory: priceHistory,
        viewCount: random.nextInt(500) + 50,
        favoriteCount: random.nextInt(100),
      );
    }).toList();
  }

  int _getPokemonId(String name) {
    final ids = {
      'Charizard': 6,
      'Blastoise': 9,
      'Venusaur': 3,
      'Pikachu': 25,
      'Mewtwo': 150,
      'Gengar': 94,
      'Dragonite': 149,
      'Gyarados': 130,
      'Alakazam': 65,
      'Machamp': 68,
      'Articuno': 144,
      'Zapdos': 145,
      'Moltres': 146,
      'Eevee': 133,
      'Snorlax': 143,
    };
    return ids[name] ?? 25;
  }

  // Start periodic price updates
  void _startPriceUpdates() {
    // In production, this would poll a real API
    // For demo, we simulate price fluctuations
    Future.delayed(const Duration(seconds: 30), () {
      _simulatePriceUpdate();
      _startPriceUpdates();
    });
  }

  void _simulatePriceUpdate() {
    final random = math.Random();
    _cryptoPrices.forEach((symbol, price) {
      final change = (random.nextDouble() - 0.5) * 0.02; // ±1% change
      _cryptoPrices[symbol] = CryptoPrice(
        symbol: symbol,
        priceUsd: price.priceUsd * (1 + change),
        change24h: price.change24h + (random.nextDouble() - 0.5) * 0.5,
        change7d: price.change7d,
        volume24h: price.volume24h,
        marketCap: price.marketCap,
        lastUpdated: DateTime.now(),
      );
    });

    // Update USD prices for listings
    final ethPrice = _cryptoPrices['ETH']?.priceUsd ?? 3245.67;
    _listings =
        _listings.map((listing) {
          return listing.copyWith(priceInUsd: listing.priceInEth * ethPrice);
        }).toList();

    notifyListeners();
  }

  // Fetch real crypto prices (production implementation)
  Future<void> fetchCryptoPrices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // CoinGecko API (free tier)
      final response = await http
          .get(
            Uri.parse(
              'https://api.coingecko.com/api/v3/simple/price?ids=ethereum,bitcoin,solana,stellar&vs_currencies=usd&include_24hr_change=true&include_7d_change=true&include_market_cap=true&include_24hr_vol=true',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        _cryptoPrices['ETH'] = CryptoPrice(
          symbol: 'ETH',
          priceUsd: (data['ethereum']['usd'] as num).toDouble(),
          change24h:
              (data['ethereum']['usd_24h_change'] as num?)?.toDouble() ?? 0,
          change7d: 0,
          volume24h: (data['ethereum']['usd_24h_vol'] as num?)?.toDouble() ?? 0,
          marketCap:
              (data['ethereum']['usd_market_cap'] as num?)?.toDouble() ?? 0,
          lastUpdated: DateTime.now(),
        );

        _cryptoPrices['BTC'] = CryptoPrice(
          symbol: 'BTC',
          priceUsd: (data['bitcoin']['usd'] as num).toDouble(),
          change24h:
              (data['bitcoin']['usd_24h_change'] as num?)?.toDouble() ?? 0,
          change7d: 0,
          volume24h: (data['bitcoin']['usd_24h_vol'] as num?)?.toDouble() ?? 0,
          marketCap:
              (data['bitcoin']['usd_market_cap'] as num?)?.toDouble() ?? 0,
          lastUpdated: DateTime.now(),
        );

        // Update listing USD prices
        final ethPrice = _cryptoPrices['ETH']?.priceUsd ?? 3245.67;
        _listings =
            _listings.map((listing) {
              return listing.copyWith(
                priceInUsd: listing.priceInEth * ethPrice,
              );
            }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching crypto prices: $e');
      _error = 'Failed to fetch prices';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new listing
  Future<NFTListing?> createListing({
    required PokeAgent pokemon,
    required double priceInEth,
    required String sellerAddress,
    required String sellerName,
    ListingType listingType = ListingType.fixedPrice,
    double? minimumBid,
    Duration? duration,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // In production: Call smart contract to list NFT
      // await _callListingContract(...)

      final ethPrice = _cryptoPrices['ETH']?.priceUsd ?? 3245.67;
      final listing = NFTListing(
        id: 'listing_${DateTime.now().millisecondsSinceEpoch}',
        pokemon: pokemon,
        sellerAddress: sellerAddress,
        sellerName: sellerName,
        priceInEth: priceInEth,
        priceInUsd: priceInEth * ethPrice,
        listedAt: DateTime.now(),
        expiresAt: duration != null ? DateTime.now().add(duration) : null,
        listingType: listingType,
        minimumBid: minimumBid,
      );

      _listings.insert(0, listing);
      notifyListeners();

      return listing;
    } catch (e) {
      _error = 'Failed to create listing: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buy a listing (fixed price)
  Future<TradeRecord?> buyListing({
    required String listingId,
    required String buyerAddress,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final listingIndex = _listings.indexWhere((l) => l.id == listingId);
      if (listingIndex == -1) throw Exception('Listing not found');

      final listing = _listings[listingIndex];
      if (listing.status != ListingStatus.active) {
        throw Exception('Listing is not active');
      }

      // In production: Execute smart contract transaction
      // await _executeTradeOnChain(...)

      // Simulate transaction delay
      await Future.delayed(const Duration(seconds: 2));

      // Create trade record
      final trade = TradeRecord(
        id: 'trade_${DateTime.now().millisecondsSinceEpoch}',
        listingId: listingId,
        pokemon: listing.pokemon,
        buyerAddress: buyerAddress,
        sellerAddress: listing.sellerAddress,
        priceInEth: listing.priceInEth,
        priceInUsd: listing.priceInUsd,
        timestamp: DateTime.now(),
        txHash: '0x${_generateTxHash()}',
        tradeType: TradeType.buy,
      );

      // Update listing status
      _listings[listingIndex] = listing.copyWith(status: ListingStatus.sold);

      // Add to trade history
      _tradeHistory.insert(0, trade);
      await _saveData();

      notifyListeners();
      return trade;
    } catch (e) {
      _error = 'Failed to buy: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Place a bid on auction
  Future<Bid?> placeBid({
    required String listingId,
    required double amount,
    required String bidderAddress,
    required String bidderName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final listingIndex = _listings.indexWhere((l) => l.id == listingId);
      if (listingIndex == -1) throw Exception('Listing not found');

      final listing = _listings[listingIndex];
      if (listing.listingType != ListingType.auction) {
        throw Exception('Not an auction listing');
      }
      if (listing.currentBid != null && amount <= listing.currentBid!) {
        throw Exception('Bid must be higher than current bid');
      }

      // In production: Submit bid to smart contract
      // await _submitBidOnChain(...)

      await Future.delayed(const Duration(seconds: 1));

      final bid = Bid(
        id: 'bid_${DateTime.now().millisecondsSinceEpoch}',
        bidderAddress: bidderAddress,
        bidderName: bidderName,
        amount: amount,
        timestamp: DateTime.now(),
        txHash: '0x${_generateTxHash()}',
      );

      final updatedBids = [...listing.bids, bid];
      _listings[listingIndex] = listing.copyWith(
        currentBid: amount,
        currentBidder: bidderAddress,
        bids: updatedBids,
      );

      notifyListeners();
      return bid;
    } catch (e) {
      _error = 'Failed to place bid: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel a listing
  Future<bool> cancelListing(String listingId) async {
    try {
      final listingIndex = _listings.indexWhere((l) => l.id == listingId);
      if (listingIndex == -1) return false;

      // In production: Call smart contract to cancel
      _listings[listingIndex] = _listings[listingIndex].copyWith(
        status: ListingStatus.cancelled,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to cancel listing: $e';
      return false;
    }
  }

  // Add to watchlist
  void addToWatchlist(String listingId) {
    _watchlist.add(listingId);
    _saveData();
    notifyListeners();
  }

  // Remove from watchlist
  void removeFromWatchlist(String listingId) {
    _watchlist.remove(listingId);
    _saveData();
    notifyListeners();
  }

  bool isInWatchlist(String listingId) => _watchlist.contains(listingId);

  // Get watchlist listings
  List<NFTListing> get watchlistListings =>
      _listings.where((l) => _watchlist.contains(l.id)).toList();

  // Filter listings
  List<NFTListing> filterListings({
    String? type,
    String? rarity,
    double? minPrice,
    double? maxPrice,
    ListingType? listingType,
    String? sortBy,
    bool ascending = true,
  }) {
    var filtered = activeListings;

    if (type != null && type.isNotEmpty) {
      filtered = filtered.where((l) => l.pokemon.type == type).toList();
    }

    if (minPrice != null) {
      filtered = filtered.where((l) => l.priceInEth >= minPrice).toList();
    }

    if (maxPrice != null) {
      filtered = filtered.where((l) => l.priceInEth <= maxPrice).toList();
    }

    if (listingType != null) {
      filtered = filtered.where((l) => l.listingType == listingType).toList();
    }

    // Sort
    switch (sortBy) {
      case 'price':
        filtered.sort(
          (a, b) =>
              ascending
                  ? a.priceInEth.compareTo(b.priceInEth)
                  : b.priceInEth.compareTo(a.priceInEth),
        );
        break;
      case 'recent':
        filtered.sort(
          (a, b) =>
              ascending
                  ? a.listedAt.compareTo(b.listedAt)
                  : b.listedAt.compareTo(a.listedAt),
        );
        break;
      case 'popular':
        filtered.sort(
          (a, b) =>
              ascending
                  ? a.viewCount.compareTo(b.viewCount)
                  : b.viewCount.compareTo(a.viewCount),
        );
        break;
      case 'change':
        filtered.sort(
          (a, b) =>
              ascending
                  ? a.priceChange24h.compareTo(b.priceChange24h)
                  : b.priceChange24h.compareTo(a.priceChange24h),
        );
        break;
    }

    return filtered;
  }

  // Get trending listings (most price increase)
  List<NFTListing> get trendingListings {
    final sorted = List<NFTListing>.from(activeListings);
    sorted.sort((a, b) => b.priceChange24h.compareTo(a.priceChange24h));
    return sorted.take(5).toList();
  }

  // Get recently listed
  List<NFTListing> get recentListings {
    final sorted = List<NFTListing>.from(activeListings);
    sorted.sort((a, b) => b.listedAt.compareTo(a.listedAt));
    return sorted.take(10).toList();
  }

  String _generateTxHash() {
    final random = math.Random();
    const chars = '0123456789abcdef';
    return List.generate(64, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
