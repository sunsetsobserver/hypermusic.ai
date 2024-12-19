// lib/widgets/left_side_panel/draggable_feature_item.dart
import 'package:flutter/material.dart';
import '../models/feature.dart';

class DraggableFeatureItem extends StatelessWidget {
  final Feature feature;

  const DraggableFeatureItem({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Draggable<Feature>(
      data: feature,
      feedback: _buildDragFeedback(context),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildItem(context),
      ),
      child: _buildItem(context),
    );
  }

  Widget _buildItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.music_note, size: 20),
          const SizedBox(width: 8),
          Text(feature.name),
        ],
      ),
    );
  }

  Widget _buildDragFeedback(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue[100],
        child: Row(
          children: [
            const Icon(Icons.music_note, size: 20),
            const SizedBox(width: 8),
            Text(feature.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
