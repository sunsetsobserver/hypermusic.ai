// lib/widgets/feature_builder/feature_node.dart

import 'package:flutter/material.dart';
import '../models/transformation.dart';
import '../models/condition.dart';
import '../models/feature.dart';
import 'transformation_node.dart';

class FeatureNode extends StatefulWidget {
  final String featureName;
  final List<Transformation> transformations;
  final Condition? condition;
  final bool isHovering;
  final bool canAcceptHover;
  final Feature feature;
  final Feature parentFeature;
  final bool isFromPT;

  final void Function(String featureName, int?) onStartingPointChanged;
  final void Function(String featureName, int?) onHowManyChanged;
  final VoidCallback onRemoveFeature;
  final VoidCallback onRemoveCondition;
  final void Function(String subFeatureName, int transIndex)
      onTransformationRemove;
  final void Function(String subFeatureName, Transformation trans)
      onTransformationAdd;
  final void Function(String subFeatureName, Transformation trans)
      onTransformationUpdate;
  final void Function(Feature feature) onCopyFeature;
  final void Function(Condition condition) onConditionAdd;

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
    required this.onTransformationUpdate,
    required this.onCopyFeature,
    required this.onConditionAdd,
    this.isFromPT = false,
  });

  @override
  State<FeatureNode> createState() => _FeatureNodeState();
}

class _FeatureNodeState extends State<FeatureNode> {
  Map<String, TextEditingController> _startingPointControllers = {};
  Map<String, TextEditingController> _howManyControllers = {};

  final GlobalKey _cardKey = GlobalKey();

  double _nodeWidth = 240;
  double extraSpacing = 40;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers for each sub-feature
    for (final subFeature in widget.feature.composites) {
      final startingPoint = widget.feature.startingPoints[subFeature.name];
      final howMany = widget.feature.howManyValues[subFeature.name];

      _startingPointControllers[subFeature.name] =
          TextEditingController(text: startingPoint?.toString() ?? '');
      _howManyControllers[subFeature.name] =
          TextEditingController(text: howMany?.toString() ?? '');
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
        _nodeWidth = box.size.width;
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

  List<Transformation> _getTransformationsForSubFeature(String subFeatureName) {
    return widget.feature.transformationsMap[subFeatureName] ?? [];
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
                          if (widget.isFromPT)
                            const Tooltip(
                              message:
                                  "This feature is from a Performative Transaction and cannot be modified",
                              child: Icon(Icons.lock, size: 16),
                            ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: Colors.red,
                            onPressed: widget.onRemoveFeature,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Add condition section
                      DragTarget<Condition>(
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    candidateData.isNotEmpty && !widget.isFromPT
                                        ? Colors.orange
                                        : Colors.grey.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: widget.condition != null
                                      ? Row(
                                          children: [
                                            const Icon(Icons.lock, size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              widget.condition!.name,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          widget.isFromPT
                                              ? 'Condition locked'
                                              : 'Drop condition here',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                ),
                                if (widget.condition != null &&
                                    !widget.isFromPT)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    color: Colors.red,
                                    onPressed: widget.onRemoveCondition,
                                  ),
                              ],
                            ),
                          );
                        },
                        onWillAcceptWithDetails: (details) =>
                            !widget.isFromPT && widget.condition == null,
                        onAcceptWithDetails: (details) {
                          if (!widget.isFromPT) {
                            setState(() {
                              widget.onConditionAdd(details.data);
                            });
                          }
                        },
                      ),
                      if (!isScalar) ...[
                        const SizedBox(height: 8),
                        ...widget.feature.composites.map((subFeature) {
                          final transformations = widget.feature
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
                                      enabled: !widget.isFromPT,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.isFromPT
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
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
                                      enabled: !widget.isFromPT,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.isFromPT
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
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
                                        color: candidateData.isNotEmpty &&
                                                !widget.isFromPT
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
                                                  onArgsChanged: widget.isFromPT
                                                      ? null
                                                      : (newArgs) {
                                                          setState(() {
                                                            t.args = newArgs;
                                                            // Use updateTransformation instead of add
                                                            widget
                                                                .onTransformationUpdate(
                                                                    subFeature
                                                                        .name,
                                                                    t);
                                                          });
                                                        },
                                                ),
                                              ),
                                              if (!widget.isFromPT)
                                                IconButton(
                                                  icon: const Icon(Icons.close,
                                                      size: 20),
                                                  color: Colors.red,
                                                  onPressed: () {
                                                    widget
                                                        .onTransformationRemove(
                                                            subFeature.name,
                                                            tIndex);
                                                  },
                                                ),
                                            ],
                                          );
                                        }),
                                        if (transformations.isEmpty)
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              widget.isFromPT
                                                  ? 'Transformations locked'
                                                  : 'Drop transformations here',
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
                                onWillAcceptWithDetails: (details) =>
                                    !widget.isFromPT,
                                onAcceptWithDetails: (details) {
                                  if (!widget.isFromPT) {
                                    final newTransformation = Transformation(
                                      details.data.name,
                                      args: List.from(details.data.args),
                                    );
                                    widget.onTransformationAdd(
                                        subFeature.name, newTransformation);
                                  }
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
