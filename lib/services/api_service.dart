import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

class ApiService {
  ApiService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  // In-memory cache to avoid burning API quota on repeated searches.
  static final Map<String, List<Recipe>> _searchCache = {};
  static final Map<int, Recipe> _detailCache = {};

  static const String _baseUrl = 'api.spoonacular.com';

  // TODO: ใส่ API key ของคุณที่นี่ (Spoonacular)
  static const String _apiKey = '27dc9b6962334072841efd90ae66c33c';

  /// Search recipes with optional filters.
  ///
  /// [type] — meal type: main course, dessert, appetizer, breakfast, etc.
  /// [cuisine] — Italian, Thai, Mexican, Japanese, Chinese, Indian, etc.
  /// [diet] — vegetarian, vegan, gluten free, etc.
  /// [maxReadyTime] — max cooking time in minutes.
  Future<List<Recipe>> searchRecipes({
    required String query,
    int number = 20,
    String? type,
    String? cuisine,
    String? diet,
    int? maxReadyTime,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // Build a cache key from all search parameters.
    final cacheKey = '$trimmed|$type|$cuisine|$diet|$maxReadyTime';
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    final params = <String, String>{
      'apiKey': _apiKey,
      'query': trimmed,
      'number': '$number',
      'addRecipeInformation': 'true',
      'fillIngredients': 'false',
    };

    if (type != null && type.isNotEmpty) params['type'] = type;
    if (cuisine != null && cuisine.isNotEmpty) params['cuisine'] = cuisine;
    if (diet != null && diet.isNotEmpty) params['diet'] = diet;
    if (maxReadyTime != null) params['maxReadyTime'] = '$maxReadyTime';

    final uri = Uri.https(_baseUrl, '/recipes/complexSearch', params);

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception(_friendlyError(res.statusCode));
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (decoded['results'] as List<dynamic>?) ?? const [];
    final recipes = results
        .whereType<Map<String, dynamic>>()
        .map(Recipe.fromSearchJson)
        .toList(growable: false);

    _searchCache[cacheKey] = recipes;
    return recipes;
  }

  Future<Recipe> fetchRecipeDetail(int recipeId) async {
    if (_detailCache.containsKey(recipeId)) {
      return _detailCache[recipeId]!;
    }

    final uri = Uri.https(_baseUrl, '/recipes/$recipeId/information', {
      'apiKey': _apiKey,
      'includeNutrition': 'false',
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception(_friendlyError(res.statusCode));
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final recipe = Recipe.fromDetailJson(decoded);
    _detailCache[recipeId] = recipe;
    return recipe;
  }

  static String _friendlyError(int statusCode) {
    switch (statusCode) {
      case 402:
        return 'API quota exceeded for today.\n'
            'The free Spoonacular plan allows ~150 requests/day.\n'
            'Please wait until tomorrow or upgrade your API key.';
      case 401:
        return 'Invalid API key. Please check your Spoonacular API key.';
      case 429:
        return 'Too many requests. Please slow down and try again.';
      case 500:
      case 502:
      case 503:
        return 'Spoonacular server error. Please try again later.';
      default:
        return 'Spoonacular error: $statusCode';
    }
  }
}
