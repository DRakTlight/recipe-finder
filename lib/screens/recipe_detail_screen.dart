import 'package:flutter/material.dart';

import '../app_flags.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/favorites_repository.dart';
import '../services/grocery_repository.dart';
import '../utils/app_theme.dart';
import '../utils/recipe_image.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _api = ApiService();
  final _favorites = FavoritesRepository();
  final _grocery = GroceryRepository();

  bool _loading = true;
  String? _error;
  Recipe? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    //จุดเชื่อมต่อ Backend
    try {
      final detail = await _api.fetchRecipeDetail(widget.recipe.id);
      if (!mounted) return;
      setState(() => _detail = detail);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addToShoppingList() async {
    final ingredients = _detail?.ingredients ?? [];
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No ingredients to add')));
      return;
    }
    //จุดเชื่อมต่อ Backend
    try {
      await _grocery.addItems(ingredients, recipeTitle: widget.recipe.title);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('${ingredients.length} items added to shopping list'),
              ],
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.recipe.title;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Sliver App Bar with image ───
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.text,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.soft,
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                ),
              ),
            ),
            actions: [
              // Favorite button
              if (AppFlags.firebaseEnabled)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.soft,
                    ),
                    child: StreamBuilder<bool>(
                      stream: _favorites.isFavoriteStream(widget.recipe.id),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data ?? false;
                        return IconButton(
                          onPressed: () async {
                            //จุดเชื่อมต่อ Backend
                            try {
                              await _favorites.toggleFavorite(widget.recipe);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              key: ValueKey(isFav),
                              color: isFav
                                  ? AppColors.favorite
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'recipe_image_${widget.recipe.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  child: RecipeImage(
                    imageUrl: widget.recipe.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // ─── Content ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meta chips
                  Row(
                    children: [
                      if (widget.recipe.readyInMinutes != null) ...[
                        _MetaPill(
                          icon: Icons.timer_outlined,
                          label: '${widget.recipe.readyInMinutes} min',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (widget.recipe.servings != null)
                        _MetaPill(
                          icon: Icons.people_outline_rounded,
                          label: '${widget.recipe.servings} servings',
                          color: AppColors.accent,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ingredients card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.card,
                    child: _loading
                        ? _buildLoading()
                        : _error != null
                        ? _buildError()
                        : _buildIngredients(),
                  ),

                  // Add to shopping list button
                  if (!_loading &&
                      _error == null &&
                      (_detail?.ingredients.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: AppFlags.firebaseEnabled
                            ? _addToShoppingList
                            : null,
                        icon: const Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Add to Shopping List',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.border,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.button,
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    if (!AppFlags.firebaseEnabled)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Requires Firebase to save shopping list',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Loading ingredients...',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Could not load ingredients',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
        ),
        const SizedBox(height: 6),
        Text(
          _error!,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retry'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredients() {
    final ingredients = _detail?.ingredients ?? const [];
    if (ingredients.isEmpty) {
      return const Text(
        'No ingredient data.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryPale,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Ingredients (${ingredients.length})',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: index.isEven ? AppColors.primary : AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ingredient,
                    style: const TextStyle(
                      color: AppColors.text,
                      height: 1.35,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Meta Pill ───

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
