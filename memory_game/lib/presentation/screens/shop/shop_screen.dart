import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/power_up_model.dart';
import '../../../data/models/level_model.dart';
import '../../../domain/services/level_generator_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';
import '../../widgets/common/game_button.dart';

/// Shop screen for purchasing power-ups, themes, and currency
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            AppStrings.shop,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        CurrencyDisplay(
                          coins: state.player.coins,
                          gems: state.player.gems,
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      tabs: const [
                        Tab(text: 'Power-ups'),
                        Tab(text: 'Themes'),
                        Tab(text: 'Currency'),
                      ],
                    ),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _PowerUpsTab(state: state),
                        _ThemesTab(state: state),
                        const _CurrencyTab(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PowerUpsTab extends StatelessWidget {
  final PlayerState state;

  const _PowerUpsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: PowerUpConfigs.all.length,
      itemBuilder: (context, index) {
        final config = PowerUpConfigs.all[index];
        final owned = state.player.getPowerUpCount(config.id);

        return _PowerUpShopItem(
          config: config,
          owned: owned,
          canAffordCoins: state.player.coins >= config.coinCost,
          canAffordGems: state.player.gems >= config.gemCost,
          onBuyWithCoins: () => _buyWithCoins(context, config),
          onBuyWithGems: () => _buyWithGems(context, config),
        );
      },
    );
  }

  void _buyWithCoins(BuildContext context, PowerUpConfig config) async {
    final playerCubit = context.read<PlayerCubit>();
    if (await playerCubit.spendCoins(config.coinCost)) {
      await playerCubit.addPowerUp(config.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchased ${config.name}! ${config.icon}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _buyWithGems(BuildContext context, PowerUpConfig config) async {
    final playerCubit = context.read<PlayerCubit>();
    if (await playerCubit.spendGems(config.gemCost)) {
      await playerCubit.addPowerUp(config.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchased ${config.name}! ${config.icon}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

class _PowerUpShopItem extends StatelessWidget {
  final PowerUpConfig config;
  final int owned;
  final bool canAffordCoins;
  final bool canAffordGems;
  final VoidCallback onBuyWithCoins;
  final VoidCallback onBuyWithGems;

  const _PowerUpShopItem({
    required this.config,
    required this.owned,
    required this.canAffordCoins,
    required this.canAffordGems,
    required this.onBuyWithCoins,
    required this.onBuyWithGems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withAlpha(77),
        ),
      ),
      child: Column(
        children: [
          // Owned badge
          if (owned > 0)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'x$owned',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Text(config.icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Text(
            config.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            config.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
          ),

          const Spacer(),

          // Buy buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: canAffordCoins ? onBuyWithCoins : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: canAffordCoins
                          ? AppColors.coinColor.withAlpha(51)
                          : Colors.grey.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💰${config.coinCost}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canAffordCoins
                            ? AppColors.coinColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: canAffordGems ? onBuyWithGems : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: canAffordGems
                          ? AppColors.gemColor.withAlpha(51)
                          : Colors.grey.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💎${config.gemCost}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canAffordGems ? AppColors.gemColor : Colors.grey,
                      ),
                    ),
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

class _ThemesTab extends StatelessWidget {
  final PlayerState state;

  const _ThemesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final themes = LevelGeneratorService.allThemes;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isOwned = state.player.unlockedThemes.contains(theme.id);
        final isEquipped = state.player.equippedTheme == theme.id;
        final canAfford = state.player.coins >= theme.cost;

        return _ThemeShopItem(
          theme: theme,
          isOwned: isOwned,
          isEquipped: isEquipped,
          canAfford: canAfford,
          onBuy: () => _buyTheme(context, theme),
          onEquip: () => _equipTheme(context, theme),
        );
      },
    );
  }

  void _buyTheme(BuildContext context, GameCardTheme theme) async {
    final playerCubit = context.read<PlayerCubit>();
    if (await playerCubit.spendCoins(theme.cost)) {
      await playerCubit.unlockTheme(theme.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unlocked ${theme.name}! ${theme.icon}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _equipTheme(BuildContext context, GameCardTheme theme) async {
    await context.read<PlayerCubit>().equipTheme(theme.id);
  }
}

class _ThemeShopItem extends StatelessWidget {
  final GameCardTheme theme;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  const _ThemeShopItem({
    required this.theme,
    required this.isOwned,
    required this.isEquipped,
    required this.canAfford,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEquipped
              ? AppColors.primary
              : AppColors.primary.withAlpha(77),
          width: isEquipped ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(theme.icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Text(
            theme.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // Preview symbols
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: theme.symbols
                .take(6)
                .map((s) => Text(s, style: const TextStyle(fontSize: 16)))
                .toList(),
          ),

          const Spacer(),

          if (isOwned)
            GameButton(
              text: isEquipped ? 'Equipped' : 'Equip',
              emoji: isEquipped ? '✓' : null,
              isSmall: true,
              width: double.infinity,
              gradient: isEquipped
                  ? AppColors.successGradient
                  : AppColors.primaryGradient,
              onPressed: isEquipped ? null : onEquip,
            )
          else
            GameButton(
              text: '💰 ${theme.cost}',
              isSmall: true,
              width: double.infinity,
              gradient: canAfford
                  ? AppColors.primaryGradient
                  : [Colors.grey, Colors.blueGrey],
              onPressed: canAfford ? onBuy : null,
            ),
        ],
      ),
    );
  }
}

class _CurrencyTab extends StatelessWidget {
  const _CurrencyTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Note about mock purchases
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withAlpha(128)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'In-app purchases require setup. See SETUP.md for instructions.',
                  style: TextStyle(color: AppColors.info, fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Coin packs
        const Text(
          '💰 Coin Packs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _CurrencyPack(
          icon: '💰',
          name: 'Small Pack',
          amount: 500,
          price: '\$0.99',
          color: AppColors.coinColor,
        ),
        _CurrencyPack(
          icon: '💰',
          name: 'Medium Pack',
          amount: 1500,
          bonus: 200,
          price: '\$2.99',
          color: AppColors.coinColor,
          isBestValue: true,
        ),
        _CurrencyPack(
          icon: '💰',
          name: 'Large Pack',
          amount: 5000,
          bonus: 1000,
          price: '\$9.99',
          color: AppColors.coinColor,
        ),

        const SizedBox(height: 24),

        // Gem packs
        const Text(
          '💎 Gem Packs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _CurrencyPack(
          icon: '💎',
          name: 'Small Pack',
          amount: 20,
          price: '\$1.99',
          color: AppColors.gemColor,
        ),
        _CurrencyPack(
          icon: '💎',
          name: 'Medium Pack',
          amount: 60,
          bonus: 10,
          price: '\$4.99',
          color: AppColors.gemColor,
        ),
        _CurrencyPack(
          icon: '💎',
          name: 'Large Pack',
          amount: 150,
          bonus: 30,
          price: '\$9.99',
          color: AppColors.gemColor,
          isBestValue: true,
        ),

        const SizedBox(height: 24),

        // Watch ad for coins
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.successGradient,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('📺', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watch Ad',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Get 30 coins for free!',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Mock ad watch
                  context.read<PlayerCubit>().addCoins(30);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('+30 coins! 💰'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.success,
                ),
                child: const Text('Watch'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrencyPack extends StatelessWidget {
  final String icon;
  final String name;
  final int amount;
  final int? bonus;
  final String price;
  final Color color;
  final bool isBestValue;

  const _CurrencyPack({
    required this.icon,
    required this.name,
    required this.amount,
    this.bonus,
    required this.price,
    required this.color,
    this.isBestValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBestValue ? AppColors.accent : color.withAlpha(77),
          width: isBestValue ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isBestValue) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BEST VALUE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '$amount',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (bonus != null)
                      Text(
                        ' +$bonus bonus',
                        style: const TextStyle(
                          color: AppColors.matchGlow,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Mock purchase - in real app, this would trigger IAP
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('IAP not configured. See SETUP.md'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
            ),
            child: Text(price),
          ),
        ],
      ),
    );
  }
}
