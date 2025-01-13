// lib/widgets/feature_builder/feature_node.dart

import 'package:flutter/material.dart';
import '../../models/running_instance.dart';

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
              IconButton(
                iconSize: 10,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                icon: Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 10,
                ),
                onPressed: onToggleExpand,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        instance.feature.name,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      if (onRemove != null) ...[
                        const SizedBox(width: 4),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: onRemove,
                            child: Icon(
                              Icons.close,
                              size: 10,
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
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
                              _updateStartPoint(startPoint);
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
