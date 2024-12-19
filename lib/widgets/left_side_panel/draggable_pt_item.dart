// lib/widgets/left_side_panel/draggable_pt_item.dart
import 'package:flutter/material.dart';
import '../models/performative_transaction.dart';

class DraggablePTItem extends StatelessWidget {
  final PerformativeTransaction pt;

  const DraggablePTItem({super.key, required this.pt});

  @override
  Widget build(BuildContext context) {
    return Draggable<PerformativeTransaction>(
      data: pt,
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
          const Icon(Icons.account_tree, size: 20),
          const SizedBox(width: 8),
          Text(pt.name),
        ],
      ),
    );
  }

  Widget _buildDragFeedback(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.purple[100],
        child: Row(
          children: [
            const Icon(Icons.account_tree, size: 20),
            const SizedBox(width: 8),
            Text(pt.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
