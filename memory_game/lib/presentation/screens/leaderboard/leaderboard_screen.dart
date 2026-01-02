import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/services/firebase_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _globalScores = [];
  List<Map<String, dynamic>> _weeklyScores = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = FirebaseService.instance.currentUser?.uid;
    _loadLeaderboards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboards() async {
    setState(() => _isLoading = true);
    
    try {
      // Load global all-time leaderboard
      final global = await FirebaseService.instance.getGlobalLeaderboard(limit: 100);
      
      // Load weekly leaderboard
      final weekly = await FirebaseService.instance.getWeeklyLeaderboard(limit: 100);

      if (mounted) {
        setState(() {
          _globalScores = global;
          _weeklyScores = weekly;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading leaderboards: $e');
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Leaderboard', style: AppTextStyles.headline3),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadLeaderboards,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: '🏆 All Time'),
              Tab(text: '📅 This Week'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Current player stats
            _buildPlayerStats(),

            // Leaderboard tabs
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLeaderboardList(_globalScores, 'global'),
                        _buildLeaderboardList(_weeklyScores, 'weekly'),
                      ],
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStats() {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final player = state.player;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(100),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎮', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 16),
              
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Stats',
                      style: AppTextStyles.headline3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatBadge(icon: '⭐', value: '${player.totalStars}', label: 'Stars'),
                        const SizedBox(width: 16),
                        _StatBadge(icon: '🎯', value: '${state.highestUnlockedLevel}', label: 'Level'),
                        const SizedBox(width: 16),
                        _StatBadge(icon: '🎮', value: '${player.totalGamesPlayed}', label: 'Games'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.2);
      },
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> scores, String type) {
    if (scores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              type == 'weekly' 
                  ? 'No scores this week yet!\nBe the first to play!' 
                  : 'No scores yet!\nStart playing to appear here!',
              style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboards,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: scores.length,
        itemBuilder: (context, index) {
          final score = scores[index];
          final isCurrentUser = score['userId'] == _currentUserId;
          final rank = index + 1;
          
          return _LeaderboardTile(
            rank: rank,
            score: score,
            isCurrentUser: isCurrentUser,
          ).animate(delay: Duration(milliseconds: 50 * index))
              .fadeIn()
              .slideX(begin: 0.1);
        },
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
            children: [
              Row(
          mainAxisSize: MainAxisSize.min,
                children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
              value,
              style: AppTextStyles.body2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
          label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withAlpha(180),
            fontSize: 10,
                ),
              ),
            ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> score;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.rank,
    required this.score,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final totalStars = score['totalStars'] ?? 0;
    final level = score['level'] ?? 1;
    final gamesPlayed = score['totalGamesPlayed'] ?? 0;

    // Rank medal
    String rankDisplay;
    Color rankColor;
    if (rank == 1) {
      rankDisplay = '🥇';
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankDisplay = '🥈';
      rankColor = Colors.grey.shade400;
    } else if (rank == 3) {
      rankDisplay = '🥉';
      rankColor = Colors.orange.shade700;
    } else {
      rankDisplay = '#$rank';
      rankColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? AppColors.accent.withAlpha(30) 
            : AppColors.surface.withAlpha(180),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser ? AppColors.accent : Colors.transparent,
          width: isCurrentUser ? 2 : 0,
        ),
        boxShadow: rank <= 3 ? [
          BoxShadow(
            color: rankColor.withAlpha(50),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: rank <= 3 
                  ? rankColor.withAlpha(30) 
                  : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Text(rankDisplay, style: const TextStyle(fontSize: 24))
                  : Text(
                      rankDisplay,
                      style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold,
                        color: rankColor,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCurrentUser ? 'You' : 'Player ${score['userId']?.toString().substring(0, 6) ?? 'Unknown'}',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? AppColors.accent : Colors.white,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('🎯 ', style: TextStyle(fontSize: 12)),
                Text(
                  'Level $level',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                    ),
                    const SizedBox(width: 12),
                    const Text('🎮 ', style: TextStyle(fontSize: 12)),
                    Text(
                      '$gamesPlayed games',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Score (stars)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalStars',
                    style: AppTextStyles.headline3.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                ],
              ),
                Text(
                'stars',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
