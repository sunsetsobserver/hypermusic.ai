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
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rule, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                condition.name,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Row(
          children: [
            Icon(Icons.rule, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              condition.name,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.0),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.rule, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                condition.name,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            Icon(Icons.drag_indicator, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
