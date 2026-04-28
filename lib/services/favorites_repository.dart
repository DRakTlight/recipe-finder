import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe.dart';

class FavoritesRepository {
  FavoritesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('favorites');

  DocumentReference<Map<String, dynamic>> docFor(int recipeId) =>
      _col.doc(recipeId.toString());

  Stream<bool> isFavoriteStream(int recipeId) {
    return docFor(recipeId).snapshots().map((snap) => snap.exists);
  }

  Stream<List<Recipe>> favoritesStream() {
    return _col
        .orderBy('title')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Recipe.fromFirestore(d.data())).toList(growable: false));
  }

  Future<void> addFavorite(Recipe recipe) async {
    await docFor(recipe.id).set(recipe.toFirestore());
  }

  Future<void> removeFavorite(int recipeId) async {
    await docFor(recipeId).delete();
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final ref = docFor(recipe.id);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set(recipe.toFirestore());
    }
  }
}

