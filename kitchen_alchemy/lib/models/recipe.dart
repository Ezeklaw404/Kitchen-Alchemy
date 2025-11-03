class Recipe {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String instructions;
  final String? thumbnailUrl;
  final String? tags;
  final String? youtubeUrl;
  final String? sourceUrl;
  final Map<String, String> ingredients; // name -> measurement

  Recipe({
    required this.id,
    required this.name,
    this.category,
    this.area,
    required this.instructions,
    this.thumbnailUrl,
    this.tags,
    this.youtubeUrl,
    this.sourceUrl,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ingredients = <String, String>{};

    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i']?.toString().trim();
      final measure = json['strMeasure$i']?.toString().trim();

      if (ing != null && ing.isNotEmpty) {
        ingredients[ing] = (measure?.isEmpty ?? true) ? '' : measure!;
      }
    }

    return Recipe(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? '',
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String? ?? '',
      thumbnailUrl: json['strMealThumb'] as String?,
      tags: json['strTags'] as String?,
      youtubeUrl: json['strYoutube'] as String?,
      sourceUrl: json['strSource'] as String?,
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbnailUrl,
      'strTags': tags,
      'strYoutube': youtubeUrl,
      'strSource': sourceUrl,
    };

    // flatten map back into numbered fields if needed
    int i = 1;
    ingredients.forEach((name, measure) {
      data['strIngredient$i'] = name;
      data['strMeasure$i'] = measure;
      i++;
    });

    return data;
  }


  @override
  String toString() {
    return 'recipe(: $id, $name)';
  }
}







