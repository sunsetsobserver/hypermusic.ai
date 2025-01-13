// draggable_condition_item.dart defines a widget for rendering a Condition as a draggable item.

import 'package:flutter/material.dart'; //For Flutter UI.
import '../../models/condition.dart'; //Importing the Condition model.

class DraggableConditionItem extends StatelessWidget {
  // condition: The Condition object to display.
  final Condition condition;

  const DraggableConditionItem({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    return Draggable<Condition>(
      data: condition,
      feedback: _buildDragFeedback(context),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildItem(context),
      ),
      child: _buildItem(context),
    );
  }

  Widget _buildItem(BuildContext context) {
    // Displays an icon and the condition's name.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.lock, size: 20),
          const SizedBox(width: 8),
          Text(condition.name),
        ],
      ),
    );
  }

  Widget _buildDragFeedback(BuildContext context) {
    // A highlighted version while dragging the condition.
    return Material(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.orange[100],
        child: Row(
          children: [
            const Icon(Icons.lock, size: 20),
            const SizedBox(width: 8),
            Text(condition.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
