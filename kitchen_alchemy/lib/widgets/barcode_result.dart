import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/widgets/new_ingredient.dart';

class BarcodeResult extends StatefulWidget {
  final String productName;
  final List<String> matchedIngredients;
  final ValueChanged<String> onAddToInventory;
  final ValueChanged<String> onAddToShoppingList;
  final VoidCallback onCancel;

  const BarcodeResult({
    super.key,
    required this.productName,
    required this.matchedIngredients,
    required this.onAddToInventory,
    required this.onAddToShoppingList,
    required this.onCancel,
  });
  @override
  State<BarcodeResult> createState() => _BarcodeResultState();
}

  class _BarcodeResultState extends State<BarcodeResult> {
    int _selectedIndex = 0;

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero, // remove default padding
        content: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              // space for the X
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Item: ${widget.productName}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (widget.matchedIngredients.isEmpty)
                    const Text('No matches found in your ingredients.')
                  else
                    ...List.generate(widget.matchedIngredients.length, (index) {
                      final ingredient = widget.matchedIngredients[index];
                      return RadioListTile<int>(
                        title: Text(ingredient),
                        value: index,
                        groupValue: _selectedIndex,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedIndex = value;
                            });
                          }
                        },
                      );
                    }),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 3,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: widget.onCancel,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.matchedIngredients.isNotEmpty) ...[
            TextButton(
              onPressed: _selectedIndex != null
                  ? () =>
                  widget.onAddToInventory(
                      widget.matchedIngredients[_selectedIndex])
                  : null,
              child: const Text('Add to Inventory'),
            ),
            TextButton(
              onPressed: _selectedIndex != null
                  ? () =>
                  widget.onAddToShoppingList(
                      widget.matchedIngredients[_selectedIndex])
                  : null,
              child: const Text('Add to Shopping List'),
            ),
          ],
          TextButton.icon(
            onPressed: () async {
              // First, close the BarcodeResult dialog
              Navigator.pop(context);

              // Then open the NewIngredient dialog
              final newName = await showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (_) => NewIngredient(),
              );

              if (newName != null) {
                // Optionally, show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$newName added to database!')),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Ingredient'),
          ),
        ],
      );
    }
  }