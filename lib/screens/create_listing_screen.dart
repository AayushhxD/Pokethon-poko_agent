import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokeagent.dart';
import '../models/trading_models.dart';
import '../services/trading_service.dart';
import '../services/wallet_service.dart';

class CreateListingScreen extends StatefulWidget {
  final PokeAgent agent;

  const CreateListingScreen({super.key, required this.agent});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _priceController = TextEditingController();
  final _minimumBidController = TextEditingController();
  ListingType _listingType = ListingType.fixedPrice;
  int _durationDays = 7;
  bool _isLoading = false;

  final Map<String, Color> _typeColors = {
    'Fire': const Color(0xFFF57D31),
    'Water': const Color(0xFF6493EB),
    'Grass': const Color(0xFF74CB48),
    'Electric': const Color(0xFFF9CF30),
    'Psychic': const Color(0xFFFB5584),
    'Ghost': const Color(0xFF70559B),
    'Dragon': const Color(0xFF7037FF),
    'Ice': const Color(0xFF9AD6DF),
    'Fighting': const Color(0xFFC12239),
    'Normal': const Color(0xFFAAA67F),
    'Poison': const Color(0xFFA43E9E),
    'Ground': const Color(0xFFDEC16B),
    'Flying': const Color(0xFFA891EC),
    'Bug': const Color(0xFFA6B91A),
    'Rock': const Color(0xFFB69E31),
    'Steel': const Color(0xFFB7B9D0),
    'Dark': const Color(0xFF75574C),
    'Fairy': const Color(0xFFE69EAC),
  };

  @override
  void dispose() {
    _priceController.dispose();
    _minimumBidController.dispose();
    super.dispose();
  }

  Color _getTypeColor(String type) {
    return _typeColors[type] ?? const Color(0xFFCD3131);
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(widget.agent.type);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF303943),
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'List for Sale',
              style: GoogleFonts.poppins(
                color: const Color(0xFF303943),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              'NFT Marketplace',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pokemon Preview Card - Enhanced
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Image section with gradient
                  Container(
                    height: 180,
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
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          widget.agent.displayImageUrl,
                          height: 140,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) => Icon(
                                Icons.catching_pokemon,
                                color: typeColor,
                                size: 80,
                              ),
                        ),
                        // Type badge
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [typeColor, typeColor.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: typeColor.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.agent.type,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // Verified badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.verified_rounded,
                              color: Colors.blue.shade500,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Info section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.agent.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF303943),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
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
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Owned',
                                    style: GoogleFonts.poppins(
                                      color: Colors.green.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatChipEnhanced(
                              Icons.flash_on_rounded,
                              'Level ${widget.agent.level}',
                              Colors.amber,
                            ),
                            const SizedBox(width: 10),
                            _buildStatChipEnhanced(
                              Icons.auto_awesome_rounded,
                              'Stage ${widget.agent.evolutionStage}',
                              Colors.purple,
                            ),
                            const SizedBox(width: 10),
                            _buildStatChipEnhanced(
                              Icons.bolt_rounded,
                              widget.agent.type,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Listing Type Selection
            Text(
              'Listing Type',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF303943),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildListingTypeOption(
                    ListingType.fixedPrice,
                    'Fixed Price',
                    Icons.sell_rounded,
                    'Set your price',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildListingTypeOption(
                    ListingType.auction,
                    'Auction',
                    Icons.gavel_rounded,
                    'Accept bids',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Price Input
            Text(
              _listingType == ListingType.fixedPrice
                  ? 'Set Price (ETH)'
                  : 'Starting Bid (ETH)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF303943),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller:
                    _listingType == ListingType.fixedPrice
                        ? _priceController
                        : _minimumBidController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF303943),
                ),
                decoration: InputDecoration(
                  prefixText: '⟠ ',
                  prefixStyle: const TextStyle(fontSize: 24),
                  hintText: '0.0000',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            if (_listingType == ListingType.auction) ...[
              const SizedBox(height: 28),

              // Duration Selection
              Text(
                'Auction Duration',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF303943),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDurationOption(1, '1 Day'),
                  const SizedBox(width: 10),
                  _buildDurationOption(3, '3 Days'),
                  const SizedBox(width: 10),
                  _buildDurationOption(7, '7 Days'),
                  const SizedBox(width: 10),
                  _buildDurationOption(14, '14 Days'),
                ],
              ),
            ],

            const SizedBox(height: 28),

            // Fee Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marketplace Fee: 2.5%',
                          style: GoogleFonts.poppins(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'A small fee is deducted upon successful sale',
                          style: GoogleFonts.poppins(
                            color: Colors.blue.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Summary
            _buildSummarySection(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  Widget _buildStatChipEnhanced(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.12), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  color: Color.alphaBlend(Colors.black38, color),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingTypeOption(
    ListingType type,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _listingType == type;
    return GestureDetector(
      onTap: () => setState(() => _listingType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFCD3131).withOpacity(0.08)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFCD3131) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFFCD3131).withOpacity(0.15)
                        : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? const Color(0xFFCD3131) : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color:
                    isSelected
                        ? const Color(0xFFCD3131)
                        : const Color(0xFF303943),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(int days, String label) {
    final isSelected = _durationDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _durationDays = days),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.purple.withOpacity(0.1)
                    : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.purple.shade400 : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? Colors.purple.shade600 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final price =
        _listingType == ListingType.fixedPrice
            ? double.tryParse(_priceController.text) ?? 0.0
            : double.tryParse(_minimumBidController.text) ?? 0.0;
    final fee = price * 0.025;
    final youReceive = price - fee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF303943),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            _listingType == ListingType.fixedPrice
                ? 'Listing Price'
                : 'Starting Bid',
            '⟠ ${price.toStringAsFixed(4)} ETH',
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            'Marketplace Fee (2.5%)',
            '- ⟠ ${fee.toStringAsFixed(4)} ETH',
            isDeduction: true,
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            'You Receive',
            '⟠ ${youReceive.toStringAsFixed(4)} ETH',
            isBold: true,
          ),
          if (_listingType == ListingType.auction) ...[
            const Divider(height: 24),
            _buildSummaryRow('Duration', '$_durationDays days'),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDeduction = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: isBold ? const Color(0xFF303943) : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color:
                isDeduction
                    ? Colors.red.shade400
                    : isBold
                    ? const Color(0xFFCD3131)
                    : const Color(0xFF303943),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCD3131), Color(0xFFE04545)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCD3131).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _listingType == ListingType.fixedPrice
                                  ? Icons.sell_rounded
                                  : Icons.gavel_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _listingType == ListingType.fixedPrice
                                  ? 'List for Sale'
                                  : 'Start Auction',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'By listing, you agree to our terms and conditions',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createListing() async {
    final price =
        _listingType == ListingType.fixedPrice
            ? double.tryParse(_priceController.text)
            : double.tryParse(_minimumBidController.text);

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid price',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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

    setState(() => _isLoading = true);

    try {
      final tradingService = context.read<TradingService>();
      final walletService = context.read<WalletService>();

      final listing = await tradingService.createListing(
        pokemon: widget.agent,
        priceInEth: price,
        sellerAddress: walletService.walletAddress ?? '0xYourWallet',
        sellerName: walletService.isConnected ? 'You' : 'Anonymous',
        listingType: _listingType,
        minimumBid: _listingType == ListingType.auction ? price : null,
        duration:
            _listingType == ListingType.auction
                ? Duration(days: _durationDays)
                : null,
      );

      if (mounted && listing != null) {
        _showSuccessDialog(listing);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create listing',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create listing: $e',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog(NFTListing listing) {
    final typeColor = _getTypeColor(widget.agent.type);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green.shade600,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Listed Successfully!',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF303943),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.agent.name} is now on the marketplace',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.network(
                            widget.agent.displayImageUrl,
                            errorBuilder:
                                (_, __, ___) => Icon(
                                  Icons.catching_pokemon,
                                  color: typeColor,
                                  size: 30,
                                ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.agent.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: const Color(0xFF303943),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    '⟠ ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    listing.priceInEth.toStringAsFixed(4),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: const Color(0xFF303943),
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to home
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
                        'Done',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to home
                      // Navigate to marketplace could be added here
                    },
                    child: Text(
                      'View in Marketplace',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
