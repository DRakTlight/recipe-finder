import 'package:flutter/material.dart';

import '../app_flags.dart';
import '../models/grocery_item.dart';
import '../services/grocery_repository.dart';
import '../utils/app_theme.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final _repo = GroceryRepository();
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _addManualItem() async {
    final text = _addController.text.trim();
    if (text.isEmpty) return;
    try {
      await _repo.addItem(text);
      _addController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    }
  }

  Future<void> _clearChecked() async {
    try {
      await _repo.clearChecked();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Completed items cleared'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppFlags.firebaseEnabled) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Shopping List')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Shopping List requires Firebase.\nPlease configure Firebase to use this feature.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            onPressed: _clearChecked,
            icon: const Icon(Icons.playlist_remove_rounded),
            tooltip: 'Clear completed',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Add item input ───
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: AppDecorations.input,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addManualItem(),
                        decoration: InputDecoration(
                          hintText: 'Add an item...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: Icon(Icons.add_shopping_cart_rounded,
                              color: AppColors.primary.withOpacity(0.6)),
                        ),
                        style: const TextStyle(color: AppColors.text, fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: IconButton(
                        onPressed: _addManualItem,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Item list ───
            Expanded(
              child: StreamBuilder<List<GroceryItem>>(
                stream: _repo.groceryStream(),
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
                        child: Text(
                          'Error loading list:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  final items = snapshot.data ?? const [];
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_basket_outlined,
                              size: 64, color: AppColors.primary.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          const Text(
                            'Your shopping list is empty',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add items manually or from a recipe',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  final unchecked = items.where((i) => !i.checked).toList();
                  final checked = items.where((i) => i.checked).toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      if (unchecked.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'To Buy',
                          count: unchecked.length,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        ...unchecked.map((item) => _GroceryTile(
                              item: item,
                              onToggle: () => _repo.toggleChecked(item.id, item.checked),
                              onRemove: () => _repo.removeItem(item.id),
                            )),
                      ],
                      if (checked.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _SectionHeader(
                          title: 'Completed',
                          count: checked.length,
                          color: AppColors.checked,
                        ),
                        const SizedBox(height: 8),
                        ...checked.map((item) => _GroceryTile(
                              item: item,
                              onToggle: () => _repo.toggleChecked(item.id, item.checked),
                              onRemove: () => _repo.removeItem(item.id),
                            )),
                      ],
                    ],
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

// ─── Section Header ───

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ─── Grocery Tile ───

class _GroceryTile extends StatelessWidget {
  const _GroceryTile({
    required this.item,
    required this.onToggle,
    required this.onRemove,
  });

  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: item.checked
              ? AppColors.checked.withOpacity(0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: item.checked ? null : AppShadows.soft,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.checked ? AppColors.checked : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: item.checked ? AppColors.checked : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: item.checked
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Name + recipe label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            color: item.checked
                                ? AppColors.textSecondary
                                : AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration:
                                item.checked ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.textSecondary,
                          ),
                        ),
                        if (item.recipeTitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.recipeTitle!,
                            style: TextStyle(
                              color: AppColors.primary.withOpacity(0.6),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Delete
                  IconButton(
                    onPressed: onRemove,
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: AppColors.textSecondary.withOpacity(0.5)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
