// lib/widgets/left_side_panel/draggable_feature_item.dart
import 'package:flutter/material.dart';
import '../../models/feature.dart';

class DraggableFeatureItem extends StatelessWidget {
  final Feature feature;

  const DraggableFeatureItem({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Feature>(
      data: feature,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            feature.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          feature.name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (feature.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      feature.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.drag_indicator),
          ],
        ),
      ),
    );
  }
}
