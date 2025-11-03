import 'package:fuzzy/fuzzy.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';

class FuzzyMatchService {
  static List<Ingredient> findMatches(
    String query,
    List<Ingredient> allIngredients, {
    int maxResults = 5,
  }) {
    final fuse = Fuzzy(
      allIngredients.map((i) => i.name).toList(),
      options: FuzzyOptions(
        threshold: 0.6, // lower = more lenient
        distance: 200,
        tokenize: false,
        findAllMatches: true, // important!
      ),
    );

    final results = fuse.search(query);

    if (results.isEmpty) {
      print("⚠️ No fuzzy matches found for '$query'");
      return [];
    }
    results.sort((a, b) => a.score.compareTo(b.score));


    // Map results to Ingredient? safely (no orElse on firstWhere)
    final List<Ingredient?> maybeMatches = results.map((r) {
      // find ingredients whose name exactly matches the fuzzy returned item (case-insensitive)
      final matchList = allIngredients
          .where((i) => i.name.toLowerCase() == r.item.toLowerCase())
          .toList();

      // return first if exists, otherwise null
      return matchList.isNotEmpty ? matchList.first : null;
    }).toList();

    // Remove nulls and deduplicate by lowercased name (keep first occurrence)
    final distinct = <String, Ingredient>{};
    for (final m in maybeMatches) {
      if (m == null) continue;
      final key = m.name.toLowerCase();
      if (!distinct.containsKey(key)) {
        distinct[key] = m;
      }
    }

    return distinct.values.take(maxResults).toList();


        //   return matchList.isNotEmpty ? matchList.first : null;
        // })
        // .whereType<Ingredient>() // removes any nulls
        // .toList();
  }
}























