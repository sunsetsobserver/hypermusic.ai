import 'package:flutter/material.dart';

class ConditionNode extends StatelessWidget {
  final String conditionName;
  final VoidCallback onRemoveCondition;

  const ConditionNode({
    super.key,
    required this.conditionName,
    required this.onRemoveCondition,
  });

  @override
  Widget build(BuildContext context) {
    // Since we're using Positioned.fill in FeatureNode,
    // ConditionNode gets exactly nodeWidth x nodeHeight from parent.
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange[50],
        ),
        child: Stack(
          children: [
            // Condition label at top center
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  color: Colors.orange,
                  child: Text(
                    conditionName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),

            // "x" button to remove condition in top right corner
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: Colors.red,
                onPressed: onRemoveCondition,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
