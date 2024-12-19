import 'package:flutter/material.dart';
import '../models/feature.dart';
import '../models/transformation.dart';
import '../models/condition.dart';
import '../models/performative_transaction.dart';
import 'feature_node.dart';
import '../../interfaces/data_interface.dart';

class _FeatureNodeData {
  Offset position;
  Feature feature;
  List<Transformation> transformations;
  Condition? condition;

  int? fixedStartingPoint;
  int? fixedHowMany;

  _FeatureNodeData({
    required this.position,
    required this.feature,
    this.transformations = const [],
    this.condition,
    this.fixedStartingPoint,
    this.fixedHowMany,
  });
}

class FeatureBuilderWorkspaceController {
  _FeatureBuilderWorkspaceState? _state;

  Future<bool> compileWorkspace(
      String newName, DataInterface dataInterface, Feature rootFeature) async {
    // Instead of using _state._featureNodes, we use rootFeature
    // For demonstration, we'll just register this rootFeature as if it's a single feature.
    // In a real scenario, you'd recursively register all sub-features.

    // Collect composite names from the root feature
    final compositeNames = rootFeature.composites.map((c) => c.name).toList();
    // Flatten transformations if needed, here we just register empty transformations for now
    await dataInterface.registerFeature(newName, compositeNames, []);

    return true;
  }

  void clearWorkspace() {
    _state?._clearAll();
  }

  void displayFeature(Feature feature) {
    _state?._displayFeature(feature);
  }
}

extension FeatureBuilderWorkspaceStateExtension
    on _FeatureBuilderWorkspaceState {
  void _clearAll() {
    setState(() {
      _featureNodes.clear();
      hoveredNodeIndex = null;
      hoveredCanAccept = false;
      _currentFeatureView = null;
    });
  }

  void _displayFeature(Feature feature) {
    _currentFeatureView = feature;
    _featureNodes.clear();

    // Special case: if this is the root "New Feature" and it's scalar (no children)
    // show empty workspace
    if (feature.name == "New Feature" && feature.isScalar) {
      // empty workspace
    } else {
      if (feature.isScalar) {
        _featureNodes.add(_createNodeDataForFeature(feature, Offset(100, 100)));
      } else {
        double startX = 50;
        double y = 100;
        for (final c in feature.composites) {
          _featureNodes.add(_createNodeDataForFeature(c, Offset(startX, y)));
          startX += 250;
        }
      }
    }
    setState(() {});
  }

  _FeatureNodeData _createNodeDataForFeature(Feature f, Offset pos) {
    return _FeatureNodeData(
      position: pos,
      feature: f,
      transformations: f.transformations.expand((tList) => tList).toList(),
    );
  }
}

class FeatureBuilderWorkspace extends StatefulWidget {
  final FeatureBuilderWorkspaceController controller;
  final void Function(Feature f, {PerformativeTransaction? pt})
      onTopLevelStructureAdded;
  final void Function(Feature updatedRoot) onFeatureStructureUpdated;

  const FeatureBuilderWorkspace({
    super.key,
    required this.controller,
    required this.onTopLevelStructureAdded,
    required this.onFeatureStructureUpdated,
  });

  @override
  State<FeatureBuilderWorkspace> createState() =>
      _FeatureBuilderWorkspaceState();
}

class _FeatureBuilderWorkspaceState extends State<FeatureBuilderWorkspace> {
  final List<_FeatureNodeData> _featureNodes = [];
  int? hoveredNodeIndex;
  bool hoveredCanAccept = false;
  Feature? _currentFeatureView;

  bool canAcceptData(Object data, _FeatureNodeData nodeData) {
    if (data is Condition) {
      return nodeData.condition == null;
    } else if (data is Transformation) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DragTarget<Object>(
            builder: (context, candidateData, rejectedData) =>
                Container(color: Colors.grey[200]),
            onWillAcceptWithDetails: (details) {
              return details.data is Feature ||
                  details.data is PerformativeTransaction;
            },
            onAcceptWithDetails: (details) {
              final data = details.data;
              if (_currentFeatureView == null) {
                _currentFeatureView = Feature(name: "New Feature");
                widget.onFeatureStructureUpdated(_currentFeatureView!);
              }

              setState(() {
                if (data is Feature) {
                  _currentFeatureView!.addComposite(data);
                  widget.onFeatureStructureUpdated(_getRootFeature());
                  widget.onTopLevelStructureAdded(data);
                  _displayFeature(_currentFeatureView!);
                } else if (data is PerformativeTransaction) {
                  _currentFeatureView!.addComposite(data.feature);
                  widget.onFeatureStructureUpdated(_getRootFeature());
                  widget.onTopLevelStructureAdded(data.feature, pt: data);
                  _displayFeature(_currentFeatureView!);
                }
              });
            },
          ),
        ),
        ..._featureNodes.asMap().entries.map((entry) {
          final nodeIndex = entry.key;
          final nodeData = entry.value;

          return Positioned(
            left: nodeData.position.dx,
            top: nodeData.position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  nodeData.position += details.delta;
                });
              },
              child: DragTarget<Object>(
                builder: (context, candidateData, rejectedData) {
                  bool isHovering = (hoveredNodeIndex == nodeIndex);
                  bool canAcceptHover = isHovering ? hoveredCanAccept : false;

                  return FeatureNode(
                    featureName: nodeData.feature.name,
                    transformations: nodeData.transformations,
                    condition: nodeData.condition,
                    isHovering: isHovering,
                    canAcceptHover: canAcceptHover,
                    onTransformationRemove: (transIndex) {
                      setState(() {
                        nodeData.transformations.removeAt(transIndex);
                      });
                    },
                    onStartingPointChanged: (intValue) {
                      setState(() {
                        nodeData.fixedStartingPoint = intValue;
                      });
                    },
                    onHowManyChanged: (intValue) {
                      setState(() {
                        nodeData.fixedHowMany = intValue;
                      });
                    },
                    onRemoveFeature: () {
                      // Remove this feature from the data model if it's a composite of _currentFeatureView
                      if (_currentFeatureView != null) {
                        final idx = _currentFeatureView!.composites
                            .indexOf(nodeData.feature);
                        if (idx >= 0) {
                          // Remove from composites and transformations
                          setState(() {
                            _currentFeatureView!.composites.removeAt(idx);
                            _currentFeatureView!.transformations.removeAt(idx);
                            _featureNodes.removeAt(nodeIndex);
                          });
                          widget.onFeatureStructureUpdated(_getRootFeature());
                          // Redisplay current feature view after removal
                          _displayFeature(_currentFeatureView!);
                        } else {
                          // If not found, just remove the node visually
                          setState(() {
                            _featureNodes.removeAt(nodeIndex);
                          });
                        }
                      } else {
                        // Just remove node visually
                        setState(() {
                          _featureNodes.removeAt(nodeIndex);
                        });
                      }
                    },
                    onRemoveCondition: () {
                      setState(() {
                        nodeData.condition = null;
                      });
                    },
                  );
                },
                onWillAcceptWithDetails: (details) {
                  final data = details.data;
                  final canAccept = canAcceptData(data, nodeData);

                  setState(() {
                    hoveredNodeIndex = nodeIndex;
                    hoveredCanAccept = canAccept;
                  });

                  return canAccept;
                },
                onLeave: (data) {
                  setState(() {
                    hoveredNodeIndex = null;
                    hoveredCanAccept = false;
                  });
                },
                onAcceptWithDetails: (details) {
                  final data = details.data;
                  setState(() {
                    if (data is Transformation) {
                      nodeData.transformations = [
                        ...nodeData.transformations,
                        data
                      ];
                    } else if (data is Condition &&
                        nodeData.condition == null) {
                      nodeData.condition = data;
                    }
                    hoveredNodeIndex = null;
                    hoveredCanAccept = false;
                  });
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Feature _getRootFeature() {
    return _currentFeatureView!;
  }
}
