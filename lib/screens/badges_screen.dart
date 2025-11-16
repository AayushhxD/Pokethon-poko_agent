import 'package:flutter/material.dart' hide Badge;
import 'package:animate_do/animate_do.dart';
import '../utils/theme.dart';
import '../services/badge_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final _badgeService = BadgeService();
  List<Badge> _unlockedBadges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    final badges = await _badgeService.getUnlockedBadges();
    setState(() {
      _unlockedBadges = badges;
      _isLoading = false;
    });
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return AppTheme.goldColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Badges Grid
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildBadgesGrid(),
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
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                Text('Badges', style: Theme.of(context).textTheme.displaySmall),
                Text(
                  '${_unlockedBadges.length}/${BadgeService.availableBadges.length} Unlocked',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.goldColor,
                  AppTheme.goldColor.withOpacity(0.6),
                ],
              ),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid() {
    final allBadgeIds = BadgeService.availableBadges.keys.toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: allBadgeIds.length,
      itemBuilder: (context, index) {
        final badgeId = allBadgeIds[index];
        final badgeTemplate = BadgeService.availableBadges[badgeId]!;
        final isUnlocked = _unlockedBadges.any((b) => b.id == badgeId);
        final unlockedBadge =
            isUnlocked
                ? _unlockedBadges.firstWhere((b) => b.id == badgeId)
                : null;

        return FadeInUp(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: _buildBadgeCard(badgeTemplate, isUnlocked, unlockedBadge),
        );
      },
    );
  }

  Widget _buildBadgeCard(Badge badge, bool isUnlocked, Badge? unlockedBadge) {
    final rarityColor = _getRarityColor(badge.rarity);

    return GestureDetector(
      onTap: () => _showBadgeDetail(badge, isUnlocked, unlockedBadge),
      child: Container(
        decoration: AppTheme.badgeDecoration(rarityColor, unlocked: isUnlocked),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isUnlocked
                        ? rarityColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 48,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Badge Name
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),

            // Rarity
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(isUnlocked ? 0.3 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.rarity.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? rarityColor : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // XP Reward
            if (isUnlocked)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: AppTheme.goldColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '+${badge.xpReward} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.goldColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              const Icon(Icons.lock, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(Badge badge, bool isUnlocked, Badge? unlockedBadge) {
    final rarityColor = _getRarityColor(badge.rarity);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: rarityColor, width: 2),
            ),
            title: Row(
              children: [
                Text(badge.icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.name,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: isUnlocked ? rarityColor : Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: rarityColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge.rarity.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: rarityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                if (isUnlocked && unlockedBadge != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.goldColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${badge.xpReward} XP Earned',
                        style: const TextStyle(
                          color: AppTheme.goldColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Unlocked: ${_formatDate(unlockedBadge.unlockedAt)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Complete the challenge to unlock!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  isUnlocked ? 'Awesome!' : 'Got it!',
                  style: TextStyle(color: rarityColor),
                ),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
