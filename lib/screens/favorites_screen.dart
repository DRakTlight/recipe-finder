import 'package:flutter/material.dart';

import '../app_flags.dart';
import '../models/recipe.dart';
import '../services/favorites_repository.dart';
import '../utils/app_theme.dart';
import '../utils/recipe_image.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppFlags.firebaseEnabled) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Favorites')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border_rounded,
                  size: 64, color: AppColors.favorite.withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text(
                'Favorites requires Firebase',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please configure Firebase to use this feature.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final repo = FavoritesRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Favorites')),
      body: SafeArea(
        child: StreamBuilder<List<Recipe>>(
          stream: repo.favoritesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: AppColors.accent.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text('Could not load favorites',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(snapshot.error.toString(),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            final recipes = snapshot.data ?? const [];
            if (recipes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border_rounded,
                        size: 64, color: AppColors.favorite.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text(
                      'No favorites yet',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap the heart icon on a recipe to save it.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = recipes[index];
                return _FavoriteCard(
                  recipe: r,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipe: r),
                      ),
                    );
                  },
                  onRemove: () async {
                    try {
                      await repo.removeFavorite(r.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Favorite Card ───

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.recipe,
    required this.onTap,
    required this.onRemove,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecorations.card,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.image),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: RecipeImage(imageUrl: recipe.imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),

              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (recipe.readyInMinutes != null) ...[
                          Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text('${recipe.readyInMinutes} min',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(width: 10),
                        ],
                        if (recipe.servings != null) ...[
                          Icon(Icons.people_outline_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text('${recipe.servings}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Remove button
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.favorite_rounded, color: AppColors.favorite, size: 22),
                tooltip: 'Remove from favorites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
