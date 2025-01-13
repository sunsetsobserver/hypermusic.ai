// draggable_transformation_item.dart defines a widget to render a Transformation as a draggable item.

import 'package:flutter/material.dart'; //Base flutter library for widgets.
import '../../models/transformation.dart'; //Importing the Transformation model.

class DraggableTransformationItem extends StatelessWidget {
  // transformation: The Transformation object represented by this widget.
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
    // Display the transformation name with an icon.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.build, size: 20),
          const SizedBox(width: 8),
          Text(transformation.name),
        ],
      ),
    );
  }

  Widget _buildDragFeedback(BuildContext context) {
    // A highlighted version of the transformation item when dragged.
    return Material(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.green[100],
        child: Row(
          children: [
            const Icon(Icons.build, size: 20),
            const SizedBox(width: 8),
            Text(transformation.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
