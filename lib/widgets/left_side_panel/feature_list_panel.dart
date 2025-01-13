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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(2.0),
      ),
      margin: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              'Features',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(4.0),
              itemCount: registry.features.length,
              itemBuilder: (context, index) {
                final feature = registry.features[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: DraggableFeatureItem(feature: feature),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
