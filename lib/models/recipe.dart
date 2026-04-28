class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.readyInMinutes,
    this.servings,
    this.ingredients = const [],
  });

  final int id;
  final String title;
  final String imageUrl;
  final int? readyInMinutes;
  final int? servings;
  final List<String> ingredients;

  Recipe copyWith({
    int? id,
    String? title,
    String? imageUrl,
    int? readyInMinutes,
    int? servings,
    List<String>? ingredients,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      readyInMinutes: readyInMinutes ?? this.readyInMinutes,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  static Recipe fromSearchJson(Map<String, dynamic> json) {
    return Recipe(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?)?.trim() ?? 'Untitled',
      imageUrl: (json['image'] as String?) ?? '',
      readyInMinutes: (json['readyInMinutes'] as num?)?.toInt(),
      servings: (json['servings'] as num?)?.toInt(),
    );
  }

  static Recipe fromDetailJson(Map<String, dynamic> json) {
    final rawIngredients = (json['extendedIngredients'] as List<dynamic>?) ?? const [];
    final ingredients = rawIngredients
        .map((e) => (e as Map<String, dynamic>)['original'] as String?)
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    return Recipe(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?)?.trim() ?? 'Untitled',
      imageUrl: (json['image'] as String?) ?? '',
      readyInMinutes: (json['readyInMinutes'] as num?)?.toInt(),
      servings: (json['servings'] as num?)?.toInt(),
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'readyInMinutes': readyInMinutes,
      'servings': servings,
      'ingredients': ingredients,
    };
  }

  static Recipe fromFirestore(Map<String, dynamic> json) {
    final rawIngredients = (json['ingredients'] as List<dynamic>?) ?? const [];
    final ingredients = rawIngredients
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    return Recipe(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?)?.trim() ?? 'Untitled',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      readyInMinutes: (json['readyInMinutes'] as num?)?.toInt(),
      servings: (json['servings'] as num?)?.toInt(),
      ingredients: ingredients,
    );
  }
}

