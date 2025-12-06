import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/power_up_model.dart';
import '../../../domain/services/level_generator_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          title: Text('Shop', style: AppTextStyles.headline3),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Power-ups'),
              Tab(text: 'Themes'),
            ],
          ),
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

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PowerUpsTab(playerState: state),
                      _ThemesTab(playerState: state),
                    ],
                  ),
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
    final success = await context.read<PlayerCubit>().buyPowerUp(id, useGems: useGems);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Purchase successful!' : 'Not enough currency!'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}

class _ThemesTab extends StatelessWidget {
  final PlayerState playerState;

  const _ThemesTab({required this.playerState});

  @override
  Widget build(BuildContext context) {
    const themes = LevelGeneratorService.themes;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isUnlocked = playerState.player.unlockedThemes.contains(theme.id);
        final isEquipped = playerState.player.equippedTheme == theme.id;

        return _ThemeItem(
          icon: theme.icon,
          name: theme.name,
          symbols: theme.symbols.take(6).join(' '),
          cost: theme.cost,
          isUnlocked: isUnlocked,
          isEquipped: isEquipped,
          onBuy: () => _buyTheme(context, theme.id, theme.cost),
          onEquip: () => context.read<PlayerCubit>().equipTheme(theme.id),
        ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.1);
      },
    );
  }

  void _buyTheme(BuildContext context, String id, int cost) async {
    final cubit = context.read<PlayerCubit>();
    final success = await cubit.spendCoins(cost);
    if (success) {
      await cubit.unlockTheme(id);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Theme unlocked!' : 'Not enough coins!'),
          backgroundColor: success ? AppColors.success : AppColors.error,
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

class _ThemeItem extends StatelessWidget {
  final String icon;
  final String name;
  final String symbols;
  final int cost;
  final bool isUnlocked;
  final bool isEquipped;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  const _ThemeItem({
    required this.icon,
    required this.name,
    required this.symbols,
    required this.cost,
    required this.isUnlocked,
    required this.isEquipped,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEquipped ? AppColors.primary : AppColors.primary.withAlpha(51),
          width: isEquipped ? 2 : 1,
        ),
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
                Text(name, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(symbols, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (!isUnlocked)
            GestureDetector(
              onTap: onBuy,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text('$cost', style: AppTextStyles.body2.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else if (isEquipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Equipped', style: AppTextStyles.body2.copyWith(color: AppColors.success)),
            )
          else
            GestureDetector(
              onTap: onEquip,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Equip', style: AppTextStyles.body2.copyWith(color: AppColors.primary)),
              ),
            ),
        ],
      ),
    );
  }
}
