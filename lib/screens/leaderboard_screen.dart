import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final service = Provider.of<LeaderboardService>(context, listen: false);
    service.changeType(LeaderboardType.values[_tabController.index]);
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
            _buildTabBar(),
            Expanded(child: _buildLeaderboardList()),
          ],
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
            const Color(0xFFFFD700).withValues(alpha: 0.15),
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
      child: Column(
        children: [
          Row(
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
                '🏆 Leaderboard',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Provider.of<LeaderboardService>(
                    context,
                    listen: false,
                  ).refresh();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCD3131).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: Color(0xFFCD3131),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Top 3 Podium
          Consumer<LeaderboardService>(
            builder: (context, service, child) {
              if (service.leaderboard.length < 3) {
                return const SizedBox.shrink();
              }
              return _buildPodium(service.leaderboard.take(3).toList());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    return FadeInDown(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _buildPodiumItem(top3[1], 2, 80, Colors.grey.shade400),
          const SizedBox(width: 8),
          // 1st Place
          _buildPodiumItem(top3[0], 1, 100, const Color(0xFFFFD700)),
          const SizedBox(width: 8),
          // 3rd Place
          _buildPodiumItem(top3[2], 3, 60, const Color(0xFFCD7F32)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardEntry entry,
    int rank,
    double height,
    Color color,
  ) {
    return Column(
      children: [
        // Avatar
        Container(
          width: rank == 1 ? 60 : 50,
          height: rank == 1 ? 60 : 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              entry.odAvatar,
              style: TextStyle(fontSize: rank == 1 ? 28 : 22),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Username
        Text(
          entry.odUsername,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Wins
        Text(
          '${entry.odWins} wins',
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        // Podium
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              rank == 1
                  ? '🥇'
                  : rank == 2
                  ? '🥈'
                  : '🥉',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFFCD3131),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '🏆 Wins'),
          Tab(text: '🔥 Streak'),
          Tab(text: '📦 Pokemon'),
          Tab(text: '⭐ XP'),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Consumer<LeaderboardService>(
      builder: (context, service, child) {
        if (service.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFCD3131)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: service.leaderboard.length,
          itemBuilder: (context, index) {
            final entry = service.leaderboard[index];
            // Skip top 3 as they're shown in podium
            if (index < 3) return const SizedBox.shrink();

            return FadeInUp(
              delay: Duration(milliseconds: (index - 3) * 50),
              child: _buildLeaderboardTile(entry, index + 1),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry, int displayRank) {
    final isCurrentUser = entry.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? const Color(0xFFCD3131).withOpacity(0.1)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? const Color(0xFFCD3131) : Colors.grey.shade200,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isCurrentUser
                      ? const Color(0xFFCD3131)
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                isCurrentUser ? entry.odRank : '$displayRank',
                style: GoogleFonts.poppins(
                  fontSize: isCurrentUser ? 11 : 14,
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(entry.odAvatar, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.odUsername,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isCurrentUser
                            ? const Color(0xFFCD3131)
                            : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.odBattles} battles • ${entry.winRate.toStringAsFixed(1)}% win rate',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Stats based on current tab
          Consumer<LeaderboardService>(
            builder: (context, service, child) {
              String value;
              String label;

              switch (service.currentType) {
                case LeaderboardType.wins:
                  value = '${entry.odWins}';
                  label = 'wins';
                  break;
                case LeaderboardType.winStreak:
                  value = '${entry.odWinStreak}';
                  label = 'streak';
                  break;
                case LeaderboardType.pokemon:
                  value = '${entry.odPokemonOwned}';
                  label = 'pokemon';
                  break;
                case LeaderboardType.xp:
                  value = '${entry.odTotalXp}';
                  label = 'XP';
                  break;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color:
                          isCurrentUser
                              ? const Color(0xFFCD3131)
                              : Colors.black87,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
