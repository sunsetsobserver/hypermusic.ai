// lib/widgets/feature_builder/feature_node.dart

import 'package:flutter/material.dart';
import '../models/transformation.dart';
import '../models/condition.dart';
import '../models/feature.dart';
import 'transformation_node.dart';
import 'condition_node.dart';

class FeatureNode extends StatefulWidget {
  final String featureName;
  final List<Transformation> transformations;
  final Condition? condition;
  final bool isHovering;
  final bool canAcceptHover;
  final Feature feature;
  final Feature parentFeature;

  final void Function(String featureName, int?) onStartingPointChanged;
  final void Function(String featureName, int?) onHowManyChanged;
  final VoidCallback onRemoveFeature;
  final VoidCallback onRemoveCondition;
  final void Function(String subFeatureName, int transIndex)
      onTransformationRemove;
  final void Function(String subFeatureName, Transformation trans)
      onTransformationAdd;

  const FeatureNode({
    super.key,
    required this.featureName,
    required this.transformations,
    required this.condition,
    required this.isHovering,
    required this.canAcceptHover,
    required this.feature,
    required this.parentFeature,
    required this.onStartingPointChanged,
    required this.onHowManyChanged,
    required this.onRemoveFeature,
    required this.onRemoveCondition,
    required this.onTransformationRemove,
    required this.onTransformationAdd,
  });

  @override
  State<FeatureNode> createState() => _FeatureNodeState();
}

class _FeatureNodeState extends State<FeatureNode> {
  Map<String, TextEditingController> _startingPointControllers = {};
  Map<String, TextEditingController> _howManyControllers = {};

  final GlobalKey _cardKey = GlobalKey();

  double _nodeHeight = 200;
  double _nodeWidth = 240;
  double _featureWidth = 200;

  double extraSpacing = 40;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
    _initializeControllers();
  }

  void _initializeControllers() {
    // Clear old controllers
    for (var controller in _startingPointControllers.values) {
      controller.dispose();
    }
    for (var controller in _howManyControllers.values) {
      controller.dispose();
    }
    _startingPointControllers = {};
    _howManyControllers = {};

    // Initialize new controllers for each sub-feature
    for (final subFeature in widget.feature.composites) {
      final startingPoint =
          widget.parentFeature.startingPoints[subFeature.name];
      final howMany = widget.parentFeature.howManyValues[subFeature.name];

      _startingPointControllers[subFeature.name] = TextEditingController(
        text: startingPoint?.toString() ?? '',
      );
      _howManyControllers[subFeature.name] = TextEditingController(
        text: howMany?.toString() ?? '',
      );
    }
  }

  @override
  void didUpdateWidget(FeatureNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feature != widget.feature ||
        oldWidget.parentFeature != widget.parentFeature) {
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    for (var controller in _startingPointControllers.values) {
      controller.dispose();
    }
    for (var controller in _howManyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateHeight() {
    if (_cardKey.currentContext != null) {
      final RenderBox box =
          _cardKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _nodeHeight = box.size.height;
        _nodeWidth = box.size.width;
        _featureWidth = _nodeWidth - extraSpacing;
      });
    }
  }

  void _updateStartingPoint(String subFeatureName, String value) {
    final intValue = int.tryParse(value);
    widget.feature.setStartingPoint(subFeatureName, intValue);
    widget.onStartingPointChanged(subFeatureName, intValue);
  }

  void _updateHowMany(String subFeatureName, String value) {
    final intValue = int.tryParse(value);
    widget.feature.setHowMany(subFeatureName, intValue);
    widget.onHowManyChanged(subFeatureName, intValue);
  }

  @override
  Widget build(BuildContext context) {
    final isScalar = widget.feature.isScalar;

    return SizedBox(
      key: _cardKey,
      width: _nodeWidth,
      child: Column(
        children: [
          Stack(
            children: [
              Card(
                color: widget.isHovering
                    ? (widget.canAcceptHover
                        ? Colors.green[100]
                        : Colors.red[100])
                    : Colors.white,
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.featureName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isScalar)
                            const Tooltip(
                              message:
                                  "Scalar features are immutable sequences that provide indices",
                              child: Icon(Icons.info_outline, size: 16),
                            ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: Colors.red,
                            onPressed: widget.onRemoveFeature,
                          ),
                        ],
                      ),
                      if (!isScalar) ...[
                        const SizedBox(height: 8),
                        ...widget.feature.composites.map((subFeature) {
                          final transformations = widget.parentFeature
                              .getTransformationsForSubFeature(subFeature.name);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Settings for ${subFeature.name}:',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _startingPointControllers[
                                          subFeature.name],
                                      decoration: const InputDecoration(
                                        labelText: 'Starting Point',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 12),
                                      onChanged: (value) {
                                        _updateStartingPoint(
                                            subFeature.name, value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          _howManyControllers[subFeature.name],
                                      decoration: const InputDecoration(
                                        labelText: 'How Many',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 12),
                                      onChanged: (value) {
                                        _updateHowMany(subFeature.name, value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Transformations for ${subFeature.name}:',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              DragTarget<Transformation>(
                                builder:
                                    (context, candidateData, rejectedData) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: candidateData.isNotEmpty
                                            ? Colors.green
                                            : Colors.grey.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ...transformations
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
                                                  args: t.args,
                                                  onArgsChanged: (newArgs) {
                                                    setState(() {
                                                      t.args = newArgs;
                                                    });
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close,
                                                    size: 20),
                                                color: Colors.red,
                                                onPressed: () {
                                                  widget.onTransformationRemove(
                                                      subFeature.name, tIndex);
                                                },
                                              ),
                                            ],
                                          );
                                        }),
                                        if (transformations.isEmpty)
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            child: const Text(
                                              'Drop transformations here',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                                onWillAccept: (data) => true,
                                onAccept: (data) {
                                  final newTransformation = Transformation(
                                    data.name,
                                    args: List.from(data.args),
                                  );
                                  widget.onTransformationAdd(
                                      subFeature.name, newTransformation);
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
