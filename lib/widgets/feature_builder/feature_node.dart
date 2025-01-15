// lib/widgets/feature_builder/feature_node.dart

import 'package:flutter/material.dart';
import '../../models/running_instance.dart';

typedef OnUpdateCallback = void Function(RunningInstance instance,
    {int? startPoint, int? howManyValues});

class FeatureNode extends StatelessWidget {
  final RunningInstance instance;
  final OnUpdateCallback onUpdate;
  final VoidCallback? onRemove;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const FeatureNode({
    super.key,
    required this.instance,
    required this.onUpdate,
    this.onRemove,
    required this.isExpanded,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    // Extract the simplified name from the instance ID
    final parts = instance.id.split('/');
    final displayName = parts.last; // Get just the last part of the path

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    if (onRemove != null)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ),
                      ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Start: ', style: TextStyle(fontSize: 9)),
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          initialValue: instance.startPoint.toString(),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 9),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                          ),
                          onChanged: (value) {
                            final startPoint = int.tryParse(value) ?? 0;
                            onUpdate(instance, startPoint: startPoint);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('N: ', style: TextStyle(fontSize: 9)),
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          initialValue: instance.howManyValues.toString(),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 9),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                          ),
                          onChanged: (value) {
                            final howMany = int.tryParse(value) ?? 1;
                            onUpdate(instance, howManyValues: howMany);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (instance.feature.condition.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'if ${instance.feature.condition}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
