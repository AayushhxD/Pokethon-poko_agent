import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareService {
  static void showShareBottomSheet(
    BuildContext context, {
    required String title,
    required String content,
    String? imageUrl,
    ShareType type = ShareType.general,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _ShareBottomSheet(
            title: title,
            content: content,
            imageUrl: imageUrl,
            type: type,
          ),
    );
  }
}

enum ShareType {
  pokemonCatch,
  battleWin,
  achievement,
  evolution,
  nftMint,
  general,
}

class _ShareBottomSheet extends StatelessWidget {
  final String title;
  final String content;
  final String? imageUrl;
  final ShareType type;

  const _ShareBottomSheet({
    required this.title,
    required this.content,
    this.imageUrl,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📤 Share Your Achievement',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                // Preview Card
                _buildPreviewCard(),
                const SizedBox(height: 20),
                // Share Options
                Text(
                  'Share via',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareOption(
                      context,
                      icon: '🐦',
                      label: 'Twitter',
                      color: const Color(0xFF1DA1F2),
                      onTap: () => _shareToTwitter(context),
                    ),
                    _buildShareOption(
                      context,
                      icon: '💬',
                      label: 'Discord',
                      color: const Color(0xFF5865F2),
                      onTap: () => _shareToDiscord(context),
                    ),
                    _buildShareOption(
                      context,
                      icon: '📱',
                      label: 'Telegram',
                      color: const Color(0xFF0088CC),
                      onTap: () => _shareToTelegram(context),
                    ),
                    _buildShareOption(
                      context,
                      icon: '📋',
                      label: 'Copy',
                      color: Colors.grey.shade600,
                      onTap: () => _copyToClipboard(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getGradientColors()[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getTypeEmoji(), style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      content,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/pokomonlogo.png',
                      width: 16,
                      height: 16,
                      errorBuilder:
                          (_, __, ___) =>
                              const Text('🔴', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PokeAgent',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '#PokeAgent #Web3Gaming',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (type) {
      case ShareType.pokemonCatch:
        return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
      case ShareType.battleWin:
        return [const Color(0xFFCD3131), const Color(0xFFEF5350)];
      case ShareType.achievement:
        return [const Color(0xFFFFD700), const Color(0xFFFFB300)];
      case ShareType.evolution:
        return [const Color(0xFF9C27B0), const Color(0xFFBA68C8)];
      case ShareType.nftMint:
        return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
      case ShareType.general:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  String _getTypeEmoji() {
    switch (type) {
      case ShareType.pokemonCatch:
        return '🎯';
      case ShareType.battleWin:
        return '🏆';
      case ShareType.achievement:
        return '🏅';
      case ShareType.evolution:
        return '✨';
      case ShareType.nftMint:
        return '💎';
      case ShareType.general:
        return '🌟';
    }
  }

  Widget _buildShareOption(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _generateShareText() {
    final emoji = _getTypeEmoji();
    return '''$emoji $title

$content

🎮 Play PokeAgent - The Web3 Pokemon Experience!
#PokeAgent #Web3Gaming #NFT #Pokemon''';
  }

  void _shareToTwitter(BuildContext context) {
    _showSnackBar(context, '🐦 Twitter share - Coming soon!');
    Navigator.pop(context);
  }

  void _shareToDiscord(BuildContext context) {
    _showSnackBar(context, '💬 Discord share - Coming soon!');
    Navigator.pop(context);
  }

  void _shareToTelegram(BuildContext context) {
    _showSnackBar(context, '📱 Telegram share - Coming soon!');
    Navigator.pop(context);
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _generateShareText()));
    _showSnackBar(context, '📋 Copied to clipboard!');
    Navigator.pop(context);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF333333),
      ),
    );
  }
}

// Reusable Share Button Widget
class ShareButton extends StatelessWidget {
  final String title;
  final String content;
  final ShareType type;
  final bool mini;

  const ShareButton({
    super.key,
    required this.title,
    required this.content,
    this.type = ShareType.general,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    if (mini) {
      return GestureDetector(
        onTap: () => _share(context),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.share_outlined,
            size: 18,
            color: Colors.black54,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _share(context),
      icon: const Icon(Icons.share, size: 18),
      label: Text(
        'Share',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _share(BuildContext context) {
    ShareService.showShareBottomSheet(
      context,
      title: title,
      content: content,
      type: type,
    );
  }
}
