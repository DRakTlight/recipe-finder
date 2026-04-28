import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    this.checked = false,
    this.recipeTitle,
    required this.addedAt,
  });

  final String id;
  final String name;
  final bool checked;
  final String? recipeTitle;
  final DateTime addedAt;

  GroceryItem copyWith({
    String? id,
    String? name,
    bool? checked,
    String? recipeTitle,
    DateTime? addedAt,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      checked: checked ?? this.checked,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'name': name,
      'checked': checked,
      'recipeTitle': recipeTitle,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  static GroceryItem fromFirestore(String docId, Map<String, dynamic> json) {
    return GroceryItem(
      id: docId,
      name: (json['name'] as String?)?.trim() ?? '',
      checked: (json['checked'] as bool?) ?? false,
      recipeTitle: json['recipeTitle'] as String?,
      addedAt: (json['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
