import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/services/ingredient_service.dart';

class NewIngredient extends StatefulWidget {
  const NewIngredient({super.key});

  @override
  State<NewIngredient> createState() => _NewIngredientState();
}

class _NewIngredientState extends State<NewIngredient> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  bool _isAdding = false;
  final _service = IngredientService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: "Ingredient name",
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isAdding
                      ? null
                      : () async {
                    final name = _controller.text.trim();
                    if (name.isEmpty) return;

                    setState(() => _isAdding = true);

                    // Check if ingredient already exists
                    final tempIng = await _service.getIngredientByName(name);
                    if (tempIng != null) {
                      setState(() {
                        _error = "This ingredient already exists";
                        _isAdding = false;
                      });
                      return;
                    }

                    // Double-check confirmation
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) =>
                          AlertDialog(
                            title: const Text("Add Ingredient?"),
                            content: Text(
                                "Are you sure you want to add '$name' to the database?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Yes, add"),
                              ),
                            ],
                          ),
                    );

                    if (confirm != true) {
                      setState(() => _isAdding = false);
                      return; // user cancelled
                    }

                    // Actually add ingredient
                    await _service.addIngredient(name);

                    Navigator.pop(context, name); // return the new ingredient
                  },
                  child: _isAdding
                      ? const CircularProgressIndicator()
                      : const Text("Add"),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 3,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}