

class Ingredient {
  final String id;
  final String name;
  final String? description;
  final String? type;
  bool isSelected;

  Ingredient({required this.id, required this.name, required this.description, required this.type, this.isSelected = false});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['strType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, description: $description, type: $type)';
  }

}
