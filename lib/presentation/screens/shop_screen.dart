import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/monetization_providers.dart';
import '../../data/models/cosmetic_model.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ショップ'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'スキン'),
              Tab(text: 'エフェクト'),
              Tab(text: 'レア'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SkinTabView(),
            _EffectTabView(),
            _RareTabView(),
          ],
        ),
      ),
    );
  }
}

/// Parcel skin tab
class _SkinTabView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skinsAsync = ref.watch(parcelSkinCosmeticsProvider);
    final userCosmetics = ref.watch(userCosmeticsProvider);

    return skinsAsync.isEmpty
        ? Center(
            child: Text(
              'スキンを読み込み中...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            padding: const EdgeInsets.all(16),
            itemCount: skinsAsync.length,
            itemBuilder: (context, index) {
              final skin = skinsAsync[index];
              return userCosmetics.when(
                data: (userCos) => _CosmeticCard(
                  cosmetic: skin,
                  isOwned: userCos.ownedCosmeticIds.contains(skin.cosmeticId),
                  onPurchase: () => _handlePurchase(context, ref, skin),
                ),
                loading: () => const _CosmeticCardSkeleton(),
                error: (err, stack) => const _CosmeticCardSkeleton(),
              );
            },
          );
  }
}

/// Effect trail tab
class _EffectTabView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectsAsync = ref.watch(effectCosmeticsProvider);
    final userCosmetics = ref.watch(userCosmeticsProvider);

    return effectsAsync.isEmpty
        ? Center(
            child: Text(
              'エフェクトを読み込み中...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            padding: const EdgeInsets.all(16),
            itemCount: effectsAsync.length,
            itemBuilder: (context, index) {
              final effect = effectsAsync[index];
              return userCosmetics.when(
                data: (userCos) => _CosmeticCard(
                  cosmetic: effect,
                  isOwned: userCos.ownedCosmeticIds.contains(effect.cosmeticId),
                  onPurchase: () => _handlePurchase(context, ref, effect),
                ),
                loading: () => const _CosmeticCardSkeleton(),
                error: (err, stack) => const _CosmeticCardSkeleton(),
              );
            },
          );
  }
}

/// Rare/featured cosmetics tab
class _RareTabView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rareAsync = ref.watch(rareCosmeticsProvider);
    final userCosmetics = ref.watch(userCosmeticsProvider);

    return rareAsync.isEmpty
        ? Center(
            child: Text(
              'レアアイテムを読み込み中...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            padding: const EdgeInsets.all(16),
            itemCount: rareAsync.length,
            itemBuilder: (context, index) {
              final rare = rareAsync[index];
              return userCosmetics.when(
                data: (userCos) => _CosmeticCard(
                  cosmetic: rare,
                  isOwned: userCos.ownedCosmeticIds.contains(rare.cosmeticId),
                  onPurchase: () => _handlePurchase(context, ref, rare),
                ),
                loading: () => const _CosmeticCardSkeleton(),
                error: (err, stack) => const _CosmeticCardSkeleton(),
              );
            },
          );
  }
}

/// Individual cosmetic card
class _CosmeticCard extends StatelessWidget {
  final Cosmetic cosmetic;
  final bool isOwned;
  final VoidCallback onPurchase;

  const _CosmeticCard({
    required this.cosmetic,
    required this.isOwned,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isOwned ? null : onPurchase,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[300],
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        cosmetic.type == CosmeticType.parcelSkin
                            ? Icons.shopping_bag
                            : Icons.sparkles,
                        size: 48,
                      ),
                    ),
                    if (isOwned)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: _RarityBadge(rarity: cosmetic.rarity),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    cosmetic.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  if (isOwned)
                    const Text(
                      '所有済み',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      '\$${cosmetic.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  const SizedBox(height: 6),
                  if (!isOwned)
                    ElevatedButton(
                      onPressed: onPurchase,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                      ),
                      child: const Text('購入'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rarity badge
class _RarityBadge extends StatelessWidget {
  final CosmeticRarity rarity;

  const _RarityBadge({required this.rarity});

  Color _getRarityColor() {
    switch (rarity) {
      case CosmeticRarity.common:
        return Colors.grey;
      case CosmeticRarity.uncommon:
        return Colors.green;
      case CosmeticRarity.rare:
        return Colors.blue;
      case CosmeticRarity.epic:
        return Colors.purple;
      case CosmeticRarity.legendary:
        return Colors.orange;
    }
  }

  String _getRarityLabel() {
    switch (rarity) {
      case CosmeticRarity.common:
        return '通常';
      case CosmeticRarity.uncommon:
        return 'アンコモン';
      case CosmeticRarity.rare:
        return 'レア';
      case CosmeticRarity.epic:
        return 'エピック';
      case CosmeticRarity.legendary:
        return 'レジェンダリー';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getRarityColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getRarityLabel(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Skeleton loading card
class _CosmeticCardSkeleton extends StatelessWidget {
  const _CosmeticCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Handle purchase action
void _handlePurchase(
  BuildContext context,
  WidgetRef ref,
  Cosmetic cosmetic,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(cosmetic.name),
        content: Text(
          '${cosmetic.description}\n\n価格: \$${cosmetic.price.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(purchaseCosmeticProvider(cosmetic.cosmeticId));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('購入しました！')),
              );
            },
            child: const Text('購入'),
          ),
        ],
      );
    },
  );
}
