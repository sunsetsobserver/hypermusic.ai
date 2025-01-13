// lib/widgets/left_side_panel/feature_list_panel.dart

import 'package:flutter/material.dart';
import '../../registry/registry.dart';
import 'draggable_feature_item.dart';

class FeatureListPanel extends StatelessWidget {
  final Registry registry;

  const FeatureListPanel({
    super.key,
    required this.registry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Features',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: registry.features.length,
                itemBuilder: (context, index) {
                  final feature = registry.features[index];
                  return DraggableFeatureItem(feature: feature);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
