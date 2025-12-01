

class Ingredient {
  final String id;
  final String name;
  final String? description;
  final String? type;
  final DateTime? dateAdded;
  bool isSelected;

  Ingredient({required this.id, required this.name, required this.description, required this.type, this.dateAdded, this.isSelected = false});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dateAdded: json['dateAdded'] != null
        ? DateTime.parse(json['dateAdded'])
        : null,
      type: json['strType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (dateAdded != null) 'dateAdded': dateAdded!.toIso8601String(),
      'type': type,
    };
  }

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, description: $description, type: $type)';
  }

}
