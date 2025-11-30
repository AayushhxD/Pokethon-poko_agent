import 'pokeagent.dart';

/// Represents a listing in the NFT marketplace
class NFTListing {
  final String id;
  final PokeAgent pokemon;
  final String sellerAddress;
  final String sellerName;
  final double priceInEth;
  final double priceInUsd;
  final DateTime listedAt;
  final DateTime? expiresAt;
  final ListingStatus status;
  final ListingType listingType;
  final double? minimumBid; // For auctions
  final double? currentBid; // For auctions
  final String? currentBidder; // For auctions
  final List<Bid> bids; // Bid history
  final PriceHistory priceHistory;
  final int viewCount;
  final int favoriteCount;

  NFTListing({
    required this.id,
    required this.pokemon,
    required this.sellerAddress,
    required this.sellerName,
    required this.priceInEth,
    required this.priceInUsd,
    required this.listedAt,
    this.expiresAt,
    this.status = ListingStatus.active,
    this.listingType = ListingType.fixedPrice,
    this.minimumBid,
    this.currentBid,
    this.currentBidder,
    this.bids = const [],
    PriceHistory? priceHistory,
    this.viewCount = 0,
    this.favoriteCount = 0,
  }) : priceHistory = priceHistory ?? PriceHistory.empty();

  // Calculate price change percentage (24h)
  double get priceChange24h {
    if (priceHistory.prices.length < 2) return 0.0;
    final oldPrice = priceHistory.prices.first.price;
    return ((priceInEth - oldPrice) / oldPrice) * 100;
  }

  bool get isPriceUp => priceChange24h >= 0;

  NFTListing copyWith({
    String? id,
    PokeAgent? pokemon,
    String? sellerAddress,
    String? sellerName,
    double? priceInEth,
    double? priceInUsd,
    DateTime? listedAt,
    DateTime? expiresAt,
    ListingStatus? status,
    ListingType? listingType,
    double? minimumBid,
    double? currentBid,
    String? currentBidder,
    List<Bid>? bids,
    PriceHistory? priceHistory,
    int? viewCount,
    int? favoriteCount,
  }) {
    return NFTListing(
      id: id ?? this.id,
      pokemon: pokemon ?? this.pokemon,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      sellerName: sellerName ?? this.sellerName,
      priceInEth: priceInEth ?? this.priceInEth,
      priceInUsd: priceInUsd ?? this.priceInUsd,
      listedAt: listedAt ?? this.listedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      listingType: listingType ?? this.listingType,
      minimumBid: minimumBid ?? this.minimumBid,
      currentBid: currentBid ?? this.currentBid,
      currentBidder: currentBidder ?? this.currentBidder,
      bids: bids ?? this.bids,
      priceHistory: priceHistory ?? this.priceHistory,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pokemon': pokemon.toJson(),
      'sellerAddress': sellerAddress,
      'sellerName': sellerName,
      'priceInEth': priceInEth,
      'priceInUsd': priceInUsd,
      'listedAt': listedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status.name,
      'listingType': listingType.name,
      'minimumBid': minimumBid,
      'currentBid': currentBid,
      'currentBidder': currentBidder,
      'bids': bids.map((b) => b.toJson()).toList(),
      'priceHistory': priceHistory.toJson(),
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
    };
  }

  factory NFTListing.fromJson(Map<String, dynamic> json) {
    return NFTListing(
      id: json['id'] as String,
      pokemon: PokeAgent.fromJson(json['pokemon'] as Map<String, dynamic>),
      sellerAddress: json['sellerAddress'] as String,
      sellerName: json['sellerName'] as String,
      priceInEth: (json['priceInEth'] as num).toDouble(),
      priceInUsd: (json['priceInUsd'] as num).toDouble(),
      listedAt: DateTime.parse(json['listedAt'] as String),
      expiresAt:
          json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'] as String)
              : null,
      status: ListingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ListingStatus.active,
      ),
      listingType: ListingType.values.firstWhere(
        (e) => e.name == json['listingType'],
        orElse: () => ListingType.fixedPrice,
      ),
      minimumBid: json['minimumBid'] as double?,
      currentBid: json['currentBid'] as double?,
      currentBidder: json['currentBidder'] as String?,
      bids:
          (json['bids'] as List?)
              ?.map((b) => Bid.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      priceHistory: PriceHistory.fromJson(
        json['priceHistory'] as Map<String, dynamic>,
      ),
      viewCount: json['viewCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
    );
  }
}

enum ListingStatus { active, sold, cancelled, expired }

enum ListingType { fixedPrice, auction, dutchAuction }

/// Represents a bid on an auction listing
class Bid {
  final String id;
  final String bidderAddress;
  final String bidderName;
  final double amount;
  final DateTime timestamp;
  final String? txHash;

  Bid({
    required this.id,
    required this.bidderAddress,
    required this.bidderName,
    required this.amount,
    required this.timestamp,
    this.txHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bidderAddress': bidderAddress,
      'bidderName': bidderName,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'txHash': txHash,
    };
  }

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'] as String,
      bidderAddress: json['bidderAddress'] as String,
      bidderName: json['bidderName'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      txHash: json['txHash'] as String?,
    );
  }
}

/// Price history for a listing
class PriceHistory {
  final List<PricePoint> prices;

  PriceHistory({required this.prices});

  factory PriceHistory.empty() => PriceHistory(prices: []);

  Map<String, dynamic> toJson() {
    return {'prices': prices.map((p) => p.toJson()).toList()};
  }

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      prices:
          (json['prices'] as List?)
              ?.map((p) => PricePoint.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PricePoint {
  final double price;
  final DateTime timestamp;

  PricePoint({required this.price, required this.timestamp});

  Map<String, dynamic> toJson() {
    return {'price': price, 'timestamp': timestamp.toIso8601String()};
  }

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      price: (json['price'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Crypto price data for real-time pricing
class CryptoPrice {
  final String symbol;
  final double priceUsd;
  final double change24h;
  final double change7d;
  final double volume24h;
  final double marketCap;
  final DateTime lastUpdated;

  CryptoPrice({
    required this.symbol,
    required this.priceUsd,
    required this.change24h,
    required this.change7d,
    required this.volume24h,
    required this.marketCap,
    required this.lastUpdated,
  });

  bool get isUp => change24h >= 0;

  factory CryptoPrice.mock(String symbol) {
    final prices = {
      'ETH': 3245.67,
      'BTC': 97234.89,
      'SOL': 178.45,
      'XLM': 0.42,
    };
    return CryptoPrice(
      symbol: symbol,
      priceUsd: prices[symbol] ?? 0.0,
      change24h: (symbol == 'ETH') ? 2.34 : -1.23,
      change7d: 5.67,
      volume24h: 15000000000,
      marketCap: 390000000000,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Trade/Transaction record
class TradeRecord {
  final String id;
  final String listingId;
  final PokeAgent pokemon;
  final String buyerAddress;
  final String sellerAddress;
  final double priceInEth;
  final double priceInUsd;
  final DateTime timestamp;
  final String txHash;
  final TradeType tradeType;

  TradeRecord({
    required this.id,
    required this.listingId,
    required this.pokemon,
    required this.buyerAddress,
    required this.sellerAddress,
    required this.priceInEth,
    required this.priceInUsd,
    required this.timestamp,
    required this.txHash,
    required this.tradeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listingId': listingId,
      'pokemon': pokemon.toJson(),
      'buyerAddress': buyerAddress,
      'sellerAddress': sellerAddress,
      'priceInEth': priceInEth,
      'priceInUsd': priceInUsd,
      'timestamp': timestamp.toIso8601String(),
      'txHash': txHash,
      'tradeType': tradeType.name,
    };
  }

  factory TradeRecord.fromJson(Map<String, dynamic> json) {
    return TradeRecord(
      id: json['id'] as String,
      listingId: json['listingId'] as String,
      pokemon: PokeAgent.fromJson(json['pokemon'] as Map<String, dynamic>),
      buyerAddress: json['buyerAddress'] as String,
      sellerAddress: json['sellerAddress'] as String,
      priceInEth: (json['priceInEth'] as num).toDouble(),
      priceInUsd: (json['priceInUsd'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      txHash: json['txHash'] as String,
      tradeType: TradeType.values.firstWhere(
        (e) => e.name == json['tradeType'],
        orElse: () => TradeType.buy,
      ),
    );
  }
}

enum TradeType { buy, sell, bid, acceptBid }

/// Market statistics
class MarketStats {
  final double totalVolume24h;
  final double totalVolumeAllTime;
  final int totalListings;
  final int totalSales;
  final double floorPrice;
  final double averagePrice;
  final int uniqueHolders;
  final int uniqueBuyers24h;

  MarketStats({
    required this.totalVolume24h,
    required this.totalVolumeAllTime,
    required this.totalListings,
    required this.totalSales,
    required this.floorPrice,
    required this.averagePrice,
    required this.uniqueHolders,
    required this.uniqueBuyers24h,
  });

  factory MarketStats.mock() {
    return MarketStats(
      totalVolume24h: 125.45,
      totalVolumeAllTime: 5678.90,
      totalListings: 342,
      totalSales: 1567,
      floorPrice: 0.015,
      averagePrice: 0.089,
      uniqueHolders: 892,
      uniqueBuyers24h: 45,
    );
  }
}
