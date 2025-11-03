import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      title: const Text('Ingredient Matches'),
      content: Column(
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
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
        if (widget.matchedIngredients.isNotEmpty) ...[
          TextButton(
            onPressed: _selectedIndex != null
                ? () => widget.onAddToInventory(widget.matchedIngredients[_selectedIndex!])
                : null,
            child: const Text('Add to Inventory'),
          ),
          TextButton(
            onPressed: _selectedIndex != null
                ? () => widget.onAddToShoppingList(widget.matchedIngredients[_selectedIndex!])
                : null,
            child: const Text('Add to Shopping List'),
          ),
        ],
      ],
    );
  }
}






