// draggable_transformation_item.dart defines a widget to render a Transformation as a draggable item.

import 'package:flutter/material.dart';
import '../../models/transformation.dart';

class DraggableTransformationItem extends StatelessWidget {
  final Transformation transformation;

  const DraggableTransformationItem({super.key, required this.transformation});

  @override
  Widget build(BuildContext context) {
    return Draggable<Transformation>(
      data: transformation,
      feedback: _buildDragFeedback(context),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildItem(context),
      ),
      child: _buildItem(context),
    );
  }

  Widget _buildItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.build, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              transformation.name,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Icon(Icons.drag_indicator, size: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildDragFeedback(BuildContext context) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(2.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              transformation.name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
