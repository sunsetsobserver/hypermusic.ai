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
  Condition? condition;

  _FeatureNodeData({
    required this.position,
    required this.feature,
  });
}

class FeatureBuilderWorkspaceController {
  _FeatureBuilderWorkspaceState? _state;

  Map<String, dynamic> _serializeFeature(Feature feature) {
    // Convert transformationsMap to a list format for serialization
    List<Map<String, dynamic>> allTransformations = [];
    feature.transformationsMap.forEach((subFeatureName, transformations) {
      for (var t in transformations) {
        allTransformations.add({
          "name": t.name,
          "args": t.args,
          "subFeatureName": subFeatureName,
        });
      }
    });

    return {
      "name": feature.name,
      "composites": feature.composites.map((c) => c.name).toList(),
      "transformations": allTransformations,
      "startingPoints": feature.startingPoints,
      "howManyValues": feature.howManyValues,
      // Add sub-features data
      "subFeatures":
          feature.composites.map((c) => _serializeFeature(c)).toList(),
    };
  }

  Future<bool> compileWorkspace(
      String newName, DataInterface dataInterface, Feature rootFeature) async {
    // First register all sub-features recursively
    for (var composite in rootFeature.composites) {
      await _registerFeatureRecursively(composite, dataInterface);
    }

    // Then register the root feature
    final featureData = _serializeFeature(rootFeature);
    featureData["name"] = newName; // Override the name for the root feature

    await dataInterface.registerFeature(
      newName,
      featureData["composites"] as List<String>,
      featureData["transformations"] as List<Map<String, dynamic>>,
      startingPoints: featureData["startingPoints"] as Map<String, dynamic>,
      howManyValues: featureData["howManyValues"] as Map<String, dynamic>,
    );

    return true;
  }

  Future<void> _registerFeatureRecursively(
      Feature feature, DataInterface dataInterface) async {
    // First register all sub-features
    for (var composite in feature.composites) {
      await _registerFeatureRecursively(composite, dataInterface);
    }

    // Then register this feature
    final featureData = _serializeFeature(feature);
    await dataInterface.registerFeature(
      feature.name,
      featureData["composites"] as List<String>,
      featureData["transformations"] as List<Map<String, dynamic>>,
      startingPoints: featureData["startingPoints"] as Map<String, dynamic>,
      howManyValues: featureData["howManyValues"] as Map<String, dynamic>,
    );
  }

  void clearWorkspace() {
    _state?._clearAll();
  }

  void displayFeature(Feature feature, {Feature? parent}) {
    _state?._displayFeature(feature, parent: parent);
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
  Feature? _currentFeatureView;
  Feature? _parentFeature;
  final List<_FeatureNodeData> _featureNodes = [];
  int? hoveredNodeIndex;
  bool hoveredCanAccept = false;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void dispose() {
    widget.controller._state = null;
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _currentFeatureView = null;
      _parentFeature = null;
      _featureNodes.clear();
    });
  }

  void _displayFeature(Feature feature, {Feature? parent}) {
    _currentFeatureView = feature;
    _parentFeature = parent;
    _featureNodes.clear();

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
    );
  }

  bool canAcceptData(Object? data, _FeatureNodeData nodeData) {
    if (data is Transformation) {
      // Only allow transformations on non-scalar features
      return !nodeData.feature.isScalar;
    }
    return false;
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
                    transformations: [],
                    condition: nodeData.condition,
                    isHovering: isHovering,
                    canAcceptHover: canAcceptHover,
                    feature: nodeData.feature,
                    parentFeature: _currentFeatureView!,
                    onTransformationRemove: (subFeatureName, transIndex) {
                      setState(() {
                        // Remove transformation from the feature
                        _currentFeatureView!.removeTransformationForSubFeature(
                            subFeatureName, transIndex);
                        widget.onFeatureStructureUpdated(_getRootFeature());
                      });
                    },
                    onTransformationAdd: (subFeatureName, trans) {
                      setState(() {
                        // Add transformation to the feature
                        _currentFeatureView!.addTransformationForSubFeature(
                            subFeatureName, trans);
                        widget.onFeatureStructureUpdated(_getRootFeature());
                      });
                    },
                    onStartingPointChanged: (featureName, intValue) {
                      setState(() {
                        _currentFeatureView!
                            .setStartingPoint(featureName, intValue);
                        widget.onFeatureStructureUpdated(_getRootFeature());
                      });
                    },
                    onHowManyChanged: (featureName, intValue) {
                      setState(() {
                        _currentFeatureView!.setHowMany(featureName, intValue);
                        widget.onFeatureStructureUpdated(_getRootFeature());
                      });
                    },
                    onRemoveFeature: () {
                      if (_currentFeatureView != null) {
                        final idx = _currentFeatureView!.composites
                            .indexOf(nodeData.feature);
                        if (idx >= 0) {
                          setState(() {
                            _currentFeatureView!.composites.removeAt(idx);
                            _featureNodes.removeAt(nodeIndex);
                          });
                          widget.onFeatureStructureUpdated(_getRootFeature());
                          _displayFeature(_currentFeatureView!);
                        } else {
                          setState(() {
                            _featureNodes.removeAt(nodeIndex);
                          });
                        }
                      } else {
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
                    if (data is Transformation && !nodeData.feature.isScalar) {
                      // Transformations are now handled by the FeatureNode's DragTargets
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
        }),
      ],
    );
  }

  Feature _getRootFeature() {
    if (_parentFeature != null) {
      Feature current = _parentFeature!;
      while (current.name != "New Feature") {
        bool found = false;
        for (final node in _featureNodes) {
          if (node.feature.composites.contains(current)) {
            current = node.feature;
            found = true;
            break;
          }
        }
        if (!found) break;
      }
      return current;
    }
    return _currentFeatureView!;
  }
}
