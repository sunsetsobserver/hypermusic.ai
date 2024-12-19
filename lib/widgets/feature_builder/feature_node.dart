// lib/widgets/feature_builder/feature_node.dart

import 'package:flutter/material.dart';
import '../models/transformation.dart';
import '../models/condition.dart';
import 'transformation_node.dart';
import 'condition_node.dart';

class FeatureNode extends StatefulWidget {
  final String featureName;
  final List<Transformation> transformations;
  final Condition? condition;
  final bool isHovering;
  final bool canAcceptHover;

  final void Function(int?) onStartingPointChanged;
  final void Function(int?) onHowManyChanged;
  final VoidCallback onRemoveFeature;
  final VoidCallback onRemoveCondition;

  final void Function(int transIndex) onTransformationRemove;

  const FeatureNode({
    super.key,
    required this.featureName,
    required this.transformations,
    required this.condition,
    required this.isHovering,
    required this.canAcceptHover,
    required this.onStartingPointChanged,
    required this.onHowManyChanged,
    required this.onRemoveFeature,
    required this.onRemoveCondition,
    required this.onTransformationRemove,
  });

  @override
  State<FeatureNode> createState() => _FeatureNodeState();
}

class _FeatureNodeState extends State<FeatureNode> {
  final TextEditingController _startingPointController =
      TextEditingController();
  final TextEditingController _howManyController = TextEditingController();

  final GlobalKey _cardKey = GlobalKey();

  double _nodeHeight = 200;
  double _nodeWidth = 240;
  double _featureWidth = 200;

  double extraSpacing = 40;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  @override
  void didUpdateWidget(covariant FeatureNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  void _updateHeight() {
    final cardContext = _cardKey.currentContext;
    if (cardContext == null) return;
    final box = cardContext.findRenderObject() as RenderBox?;
    if (box == null) return;
    final cardHeight = box.size.height;
    final newHeight = cardHeight + extraSpacing;
    if ((newHeight - _nodeHeight).abs() > 1e-3) {
      setState(() {
        _nodeHeight = newHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    if (widget.isHovering) {
      borderColor = widget.canAcceptHover ? Colors.green : Colors.red;
    }

    return SizedBox(
      width: _nodeWidth,
      height: _nodeHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.condition != null)
            Positioned.fill(
              child: ConditionNode(
                conditionName: widget.condition!.name,
                onRemoveCondition: widget.onRemoveCondition,
              ),
            ),
          // The feature card is placed at the bottom center
          Positioned(
            left: (_nodeWidth - _featureWidth) / 2,
            bottom: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _featureWidth),
              // Use a Stack here so we can position the close button relative to the card
              child: Stack(
                key: _cardKey,
                children: [
                  Container(
                    decoration: borderColor != null
                        ? BoxDecoration(
                            border: Border.all(color: borderColor, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          )
                        : null,
                    child: Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.featureName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: _startingPointController,
                                    decoration: const InputDecoration(
                                      labelText: "Start",
                                      hintText: "runtime?",
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final intValue = int.tryParse(value);
                                      widget.onStartingPointChanged(intValue);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: _howManyController,
                                    decoration: const InputDecoration(
                                      labelText: "HowMany",
                                      hintText: "runtime?",
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final intValue = int.tryParse(value);
                                      widget.onHowManyChanged(intValue);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...widget.transformations
                                .asMap()
                                .entries
                                .map((transEntry) {
                              final tIndex = transEntry.key;
                              final t = transEntry.value;
                              return Row(
                                children: [
                                  Expanded(
                                    child: TransformationNode(
                                      transformationName: t.name,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    color: Colors.red,
                                    onPressed: () {
                                      widget.onTransformationRemove(tIndex);
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Position the feature close button relative to the card
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.red,
                      onPressed: widget.onRemoveFeature,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
