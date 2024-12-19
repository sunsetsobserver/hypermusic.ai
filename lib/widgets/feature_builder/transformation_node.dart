// lib/widgets/feature_builder/transformation_node.dart
import 'package:flutter/material.dart';

class TransformationNode extends StatelessWidget {
  final String transformationName;

  const TransformationNode({super.key, required this.transformationName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const Icon(Icons.settings, size: 16),
          const SizedBox(width: 4),
          Text(transformationName),
        ],
      ),
    );
  }
}
