import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/user_stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<UserStatsService>(
          builder: (context, stats, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildOverviewCards(stats),
                  const SizedBox(height: 24),
                  _buildWinRateChart(stats),
                  const SizedBox(height: 24),
                  _buildBattleStats(stats),
                  const SizedBox(height: 24),
                  _buildAchievements(stats),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.12),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '📊 My Stats',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.insights, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Analytics',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(UserStatsService stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FadeInLeft(
                  child: _buildStatCard(
                    icon: '🏆',
                    title: 'Total Wins',
                    value: '${stats.totalWins}',
                    color: const Color(0xFFFFD700),
                    subtitle: '${stats.formattedWinRate} win rate',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FadeInRight(
                  child: _buildStatCard(
                    icon: '⚔️',
                    title: 'Battles',
                    value: '${stats.totalBattles}',
                    color: const Color(0xFFCD3131),
                    subtitle: '${stats.totalLosses} losses',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FadeInLeft(
                  delay: const Duration(milliseconds: 100),
                  child: _buildStatCard(
                    icon: '🔥',
                    title: 'Best Streak',
                    value: '${stats.bestStreak}',
                    color: Colors.orange,
                    subtitle: 'Current: ${stats.currentStreak}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FadeInRight(
                  delay: const Duration(milliseconds: 100),
                  child: _buildStatCard(
                    icon: '⭐',
                    title: 'Total XP',
                    value: '${stats.totalXpEarned}',
                    color: Colors.purple,
                    subtitle: 'Experience earned',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinRateChart(UserStatsService stats) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
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
              'Battle Performance',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Pie Chart
                  Expanded(
                    child:
                        stats.totalBattles > 0
                            ? PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    value: stats.totalWins.toDouble(),
                                    title: '${stats.formattedWinRate}',
                                    color: const Color(0xFF4CAF50),
                                    radius: 50,
                                    titleStyle: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: stats.totalLosses.toDouble(),
                                    title: '',
                                    color: const Color(0xFFCD3131),
                                    radius: 45,
                                  ),
                                ],
                              ),
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart_rounded,
                                    size: 48,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No battles yet',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                  // Legend
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        'Wins',
                        stats.totalWins,
                        const Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        'Losses',
                        stats.totalLosses,
                        const Color(0xFFCD3131),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '$value',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBattleStats(UserStatsService stats) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFCD3131).withOpacity(0.1),
              const Color(0xFFCD3131).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFCD3131).withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📈', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Detailed Stats',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Pokemon Owned',
              '${stats.ownedPokemonCount}',
              Icons.catching_pokemon,
            ),
            _buildDetailRow('Win Rate', stats.formattedWinRate, Icons.percent),
            _buildDetailRow(
              'Current Streak',
              '${stats.currentStreak} 🔥',
              Icons.local_fire_department,
            ),
            _buildDetailRow(
              'Best Streak',
              '${stats.bestStreak} ⭐',
              Icons.emoji_events,
            ),
            _buildDetailRow(
              'Total XP Earned',
              '${stats.totalXpEarned}',
              Icons.star,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFCD3131)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(UserStatsService stats) {
    final achievements = [
      {
        'icon': '🎯',
        'title': 'First Win',
        'description': 'Win your first battle',
        'unlocked': stats.totalWins >= 1,
      },
      {
        'icon': '⚡',
        'title': 'Battle Master',
        'description': 'Win 10 battles',
        'unlocked': stats.totalWins >= 10,
      },
      {
        'icon': '🔥',
        'title': 'On Fire',
        'description': 'Get a 5 win streak',
        'unlocked': stats.bestStreak >= 5,
      },
      {
        'icon': '🏆',
        'title': 'Champion',
        'description': 'Win 50 battles',
        'unlocked': stats.totalWins >= 50,
      },
      {
        'icon': '📦',
        'title': 'Collector',
        'description': 'Own 10 Pokemon',
        'unlocked': stats.ownedPokemonCount >= 10,
      },
      {
        'icon': '⭐',
        'title': 'XP Master',
        'description': 'Earn 1000 XP',
        'unlocked': stats.totalXpEarned >= 1000,
      },
    ];

    final unlockedCount =
        achievements.where((a) => a['unlocked'] as bool).length;

    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🏅 Achievements',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unlockedCount/${achievements.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF8C00),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isUnlocked = achievement['unlocked'] as bool;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isUnlocked
                            ? const Color(0xFFFFD700).withOpacity(0.15)
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          isUnlocked
                              ? const Color(0xFFFFD700)
                              : Colors.grey.shade300,
                      width: isUnlocked ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isUnlocked ? achievement['icon'] as String : '🔒',
                        style: TextStyle(
                          fontSize: 28,
                          color: isUnlocked ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        achievement['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? Colors.black87 : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}
