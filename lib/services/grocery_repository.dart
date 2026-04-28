import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/grocery_item.dart';

class GroceryRepository {
  GroceryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('shopping_list');

  /// Add multiple ingredients at once (from a recipe).
  Future<void> addItems(List<String> items, {String? recipeTitle}) async {
    final batch = _firestore.batch();
    final now = DateTime.now();
    for (final item in items) {
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;
      final doc = _col.doc(); // auto-id
      batch.set(doc, GroceryItem(
        id: doc.id,
        name: trimmed,
        recipeTitle: recipeTitle,
        addedAt: now,
      ).toFirestore());
    }
    await batch.commit();
  }

  /// Add a single item (manual entry).
  Future<void> addItem(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _col.add(GroceryItem(
      id: '',
      name: trimmed,
      addedAt: DateTime.now(),
    ).toFirestore());
  }

  /// Toggle the checked state of an item.
  Future<void> toggleChecked(String docId, bool currentValue) async {
    await _col.doc(docId).update({'checked': !currentValue});
  }

  /// Delete a single item.
  Future<void> removeItem(String docId) async {
    await _col.doc(docId).delete();
  }

  /// Delete all checked items.
  Future<void> clearChecked() async {
    final snap = await _col.where('checked', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Real‑time stream of all grocery items, ordered by addedAt.
  Stream<List<GroceryItem>> groceryStream() {
    return _col
        .orderBy('addedAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GroceryItem.fromFirestore(d.id, d.data()))
            .toList(growable: false));
  }
}
