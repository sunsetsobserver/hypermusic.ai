// lib/widgets/feature_builder/feature_node.dart

import 'package:flutter/material.dart';
import '../../models/running_instance.dart';
import '../../models/feature.dart';

class FeatureNode extends StatelessWidget {
  final RunningInstance instance;
  final Function(RunningInstance) onUpdate;
  final VoidCallback? onRemove;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const FeatureNode({
    super.key,
    required this.instance,
    required this.onUpdate,
    this.onRemove,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  void _updateFeature(Feature updatedFeature) {
    onUpdate(
      RunningInstance(
        id: instance.id,
        feature: updatedFeature,
        startPoint: instance.startPoint,
        howManyValues: instance.howManyValues,
        transformationStartIndex: instance.transformationStartIndex,
        transformationEndIndex: instance.transformationEndIndex,
      ),
    );
  }

  void _updateStartPoint(int newStartPoint) {
    onUpdate(
      instance.copyWith(startPoint: newStartPoint),
    );
  }

  void _updateHowManyValues(int newHowManyValues) {
    onUpdate(
      instance.copyWith(howManyValues: newHowManyValues),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggleExpand,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!instance.feature.isScalar) ...[
              Icon(
                isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          instance.feature.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Start: ', style: TextStyle(fontSize: 12)),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            initialValue: instance.startPoint.toString(),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              final startPoint = int.tryParse(value) ?? 0;
                              _updateStartPoint(startPoint);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('N: ', style: TextStyle(fontSize: 12)),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            initialValue: instance.howManyValues.toString(),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              final howMany = int.tryParse(value) ?? 1;
                              _updateHowManyValues(howMany);
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
      ),
    );
  }
}
