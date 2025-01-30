// category_section.dart defines a generic widget that displays a category name and a list of items.
// It uses a builder to create widgets for each item, making this component reusable.

import 'package:flutter/material.dart'; //For base widgets.

class CategorySection<T> extends StatelessWidget {
  // categoryName: The header text for this section (e.g. "Basic", "Custom", "Collected").
  // items: The list of items to display in this category.
  // itemBuilder: A function that takes a BuildContext and an item, and returns a widget to display that item.
  final String categoryName;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;

  const CategorySection({
    super.key,
    required this.categoryName,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Creates a column with a category title and the list of item widgets.
    return Padding(
      // Add vertical padding for spacing.
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the category name in a slightly bold style.
          Text(
            categoryName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          // Build the list of items using a column.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                // Map each item to a widget returned by itemBuilder.
                .map((item) => itemBuilder(context, item))
                .toList(),
          ),
        ],
      ),
    );
  }
}
