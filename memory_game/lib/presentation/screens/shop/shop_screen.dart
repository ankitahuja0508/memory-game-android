import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/power_up_model.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

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
          title: Text('Shop', style: AppTextStyles.headline3),
          centerTitle: true,
        ),
        body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            return Column(
              children: [
                // Currency Display
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CurrencyDisplay(
                    coins: state.player.coins,
                    gems: state.player.gems,
                  ),
                ),
                
                // Info text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Themes can be unlocked from the home screen!',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Power-ups List
                Expanded(
                  child: _PowerUpsTab(playerState: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PowerUpsTab extends StatelessWidget {
  final PlayerState playerState;

  const _PowerUpsTab({required this.playerState});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: PowerUpConfigs.all.length,
      itemBuilder: (context, index) {
        final config = PowerUpConfigs.all[index];
        final owned = playerState.player.getPowerUpCount(config.id);

        return _ShopItem(
          icon: config.icon,
          name: config.name,
          description: config.description,
          coinCost: config.coinCost,
          gemCost: config.gemCost,
          owned: owned,
          onBuyWithCoins: () => _buyPowerUp(context, config.id, false),
          onBuyWithGems: () => _buyPowerUp(context, config.id, true),
        ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.1);
      },
    );
  }

  void _buyPowerUp(BuildContext context, String id, bool useGems) async {
    final config = PowerUpConfigs.getConfigById(id);
    final success = await context.read<PlayerCubit>().buyPowerUp(id, useGems: useGems);
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    success ? (config?.icon ?? '🎁') : '😢',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        success ? 'Power-up acquired!' : 'Oops!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        success 
                            ? '${config?.name ?? 'Item'} added to inventory' 
                            : 'Not enough ${useGems ? 'gems' : 'coins'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          elevation: 8,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _ShopItem extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final int coinCost;
  final int gemCost;
  final int owned;
  final VoidCallback onBuyWithCoins;
  final VoidCallback onBuyWithGems;

  const _ShopItem({
    required this.icon,
    required this.name,
    required this.description,
    required this.coinCost,
    required this.gemCost,
    required this.owned,
    required this.onBuyWithCoins,
    required this.onBuyWithGems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('x$owned', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onBuyWithCoins,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.coinColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('$coinCost', style: AppTextStyles.caption.copyWith(color: AppColors.coinColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onBuyWithGems,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gemColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('$gemCost', style: AppTextStyles.caption.copyWith(color: AppColors.gemColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

