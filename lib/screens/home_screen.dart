import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/recipe_image.dart';
import 'recipe_detail_screen.dart';

// ─── Category data ───
class _Category {
  const _Category(this.label, this.icon, this.type);
  final String label;
  final IconData icon;
  final String? type; // Spoonacular meal type or null for 'All'
}

const _categories = <_Category>[
  _Category('All', Icons.restaurant_menu_rounded, null),
  _Category('Breakfast', Icons.free_breakfast_rounded, 'breakfast'),
  _Category('Main Course', Icons.dinner_dining_rounded, 'main course'),
  _Category('Salad', Icons.eco_rounded, 'salad'),
  _Category('Soup', Icons.soup_kitchen_rounded, 'soup'),
  _Category('Dessert', Icons.cake_rounded, 'dessert'),
  _Category('Snack', Icons.cookie_rounded, 'snack'),
  _Category('Beverage', Icons.local_cafe_rounded, 'beverage'),
];

const _cuisines = [
  'Italian', 'Thai', 'Mexican', 'Japanese', 'Chinese',
  'Indian', 'American', 'Mediterranean', 'Korean', 'French',
];

const _diets = ['Vegetarian', 'Vegan', 'Gluten Free', 'Dairy Free'];

// ───────────────────────────────────────────────────
// Home Screen
// ───────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _controller = TextEditingController(text: 'chicken');

  bool _loading = false;
  String? _error;
  List<Recipe> _recipes = const [];

  // Filters
  int _selectedCategory = 0;
  String? _selectedCuisine;
  String? _selectedDiet;
  int? _maxReadyTime;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCuisine != null) count++;
    if (_selectedDiet != null) count++;
    if (_maxReadyTime != null) count++;
    return count;
  }

  Future<void> _performSearch() async {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await _api.searchRecipes(
        query: trimmed,
        type: _categories[_selectedCategory].type,
        cuisine: _selectedCuisine,
        diet: _selectedDiet,
        maxReadyTime: _maxReadyTime,
      );
      if (!mounted) return;
      setState(() => _recipes = results);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _recipes = const [];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onCategoryTap(int index) {
    setState(() => _selectedCategory = index);
    _performSearch();
  }

  void _showFilterSheet() {
    String? tempCuisine = _selectedCuisine;
    String? tempDiet = _selectedDiet;
    int? tempMaxTime = _maxReadyTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Filters',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempCuisine = null;
                            tempDiet = null;
                            tempMaxTime = null;
                          });
                        },
                        child: const Text('Reset', style: TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Cuisine
                  const Text('Cuisine', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cuisines.map((c) {
                      final selected = tempCuisine == c;
                      return ChoiceChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (v) => setSheetState(() => tempCuisine = v ? c : null),
                        selectedColor: AppColors.primaryPale,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.text,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                          side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Diet
                  const Text('Diet', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _diets.map((d) {
                      final selected = tempDiet == d.toLowerCase();
                      return ChoiceChip(
                        label: Text(d),
                        selected: selected,
                        onSelected: (v) =>
                            setSheetState(() => tempDiet = v ? d.toLowerCase() : null),
                        selectedColor: AppColors.primaryPale,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.text,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                          side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Max cooking time
                  Row(
                    children: [
                      const Text('Max Cooking Time',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                      const Spacer(),
                      Text(
                        tempMaxTime == null ? 'Any' : '≤ ${tempMaxTime!} min',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: (tempMaxTime ?? 120).toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 7,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primaryPale,
                    label: tempMaxTime == null ? 'Any' : '${tempMaxTime!} min',
                    onChanged: (v) {
                      setSheetState(() {
                        final val = v.round();
                        tempMaxTime = val >= 120 ? null : val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedCuisine = tempCuisine;
                          _selectedDiet = tempDiet;
                          _maxReadyTime = tempMaxTime;
                        });
                        _performSearch();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Apply Filters',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recipe Finder',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'What would you like to cook?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter button
                  _FilterButton(
                    activeCount: _activeFilterCount,
                    onTap: _showFilterSheet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Search bar ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: AppDecorations.input,
                child: TextField(
                  controller: _controller,
                  enabled: !_loading,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search recipes (e.g., pasta)',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary.withOpacity(0.6)),
                    suffixIcon: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: _performSearch,
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                  ),
                  style: const TextStyle(color: AppColors.text, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Category chips ───
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final selected = _selectedCategory == index;
                  return GestureDetector(
                    onTap: () => _onCategoryTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: AppDecorations.chip(selected: selected),
                      child: Row(
                        children: [
                          Icon(cat.icon,
                              size: 16,
                              color: selected ? Colors.white : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            cat.label,
                            style: TextStyle(
                              color: selected ? Colors.white : AppColors.text,
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ─── Results ───
            Expanded(
              child: _Body(
                loading: _loading,
                error: _error,
                recipes: _recipes,
                onTapRecipe: (recipe) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Badge Button ───

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onTap});
  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: activeCount > 0 ? AppColors.primaryPale : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.soft,
          border: Border.all(
            color: activeCount > 0 ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.tune_rounded,
                size: 22,
                color: activeCount > 0 ? AppColors.primary : AppColors.textSecondary),
            if (activeCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$activeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Body (results / loading / error) ───

class _Body extends StatelessWidget {
  const _Body({
    required this.loading,
    required this.error,
    required this.recipes,
    required this.onTapRecipe,
  });

  final bool loading;
  final String? error;
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onTapRecipe;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _ShimmerCard(),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.accent.withOpacity(0.5)),
              const SizedBox(height: 12),
              const Text('Could not load recipes',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text)),
              const SizedBox(height: 6),
              Text(error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('No results found',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text)),
            const SizedBox(height: 6),
            const Text('Try another keyword or filter.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = recipes[index];
        return _RecipeCard(recipe: r, onTap: () => onTapRecipe(r));
      },
    );
  }
}

// ─── Shimmer loading placeholder ───

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.08 + 0.06 * (0.5 + 0.5 * (_controller.value * 2 - 1).abs());
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.text.withOpacity(opacity),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        );
      },
    );
  }
}

// ─── Recipe Card ───

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.onTap});
  final Recipe recipe;
  final VoidCallback onTap;

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
                  width: 80,
                  height: 80,
                  child: RecipeImage(imageUrl: recipe.imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),

              // Text
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (recipe.readyInMinutes != null) ...[
                          _InfoPill(
                            icon: Icons.timer_outlined,
                            label: '${recipe.readyInMinutes} min',
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (recipe.servings != null)
                          _InfoPill(
                            icon: Icons.people_outline_rounded,
                            label: '${recipe.servings}',
                            color: AppColors.accent,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info Pill ───

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
