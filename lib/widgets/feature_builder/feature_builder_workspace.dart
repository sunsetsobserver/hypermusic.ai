import 'package:flutter/material.dart';
import '../models/feature.dart';
import '../models/transformation.dart';
import '../models/condition.dart';
import '../models/performative_transaction.dart';
import 'feature_node.dart';
import '../../interfaces/data_interface.dart';
import '../left_side_panel/left_side_panel.dart';
import '../../mock/user_toolbox.dart';
import '../../mock/mock_data_store.dart';

class _FeatureNodeData {
  Offset position;
  Feature feature;
  Condition? condition;
  bool isFromPT;

  _FeatureNodeData({
    required this.position,
    required this.feature,
    this.isFromPT = false,
  });
}

class FeatureBuilderWorkspaceController {
  _FeatureBuilderWorkspaceState? _state;

  Map<String, dynamic> _serializeFeature(Feature feature) {
    // Collect all transformations for this feature
    List<Map<String, dynamic>> allTransformations = [];
    for (final entry in feature.transformationsMap.entries) {
      for (final trans in entry.value) {
        allTransformations.add({
          "subFeatureName": entry.key,
          "name": trans.name,
          "args": trans.args,
        });
      }
    }

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
      await _state?._registerFeatureRecursively(composite, dataInterface);
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
  final DataInterface dataInterface;

  const FeatureBuilderWorkspace({
    super.key,
    required this.controller,
    required this.onTopLevelStructureAdded,
    required this.onFeatureStructureUpdated,
    required this.dataInterface,
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

  Map<String, dynamic> _serializeFeature(Feature feature) {
    // Collect all transformations for this feature
    List<Map<String, dynamic>> allTransformations = [];
    for (final entry in feature.transformationsMap.entries) {
      for (final trans in entry.value) {
        allTransformations.add({
          "subFeatureName": entry.key,
          "name": trans.name,
          "args": trans.args,
        });
      }
    }

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

  Future<void> _registerFeatureRecursively(
      Feature feature, DataInterface dataInterface) async {
    // First register all sub-features
    for (var composite in feature.composites) {
      await _registerFeatureRecursively(composite, dataInterface);
    }

    // Then register this feature
    final featureData = _serializeFeature(feature);

    // Update the database through dataInterface
    await dataInterface.registerFeature(
      feature.name,
      featureData["composites"] as List<String>,
      featureData["transformations"] as List<Map<String, dynamic>>,
      startingPoints: featureData["startingPoints"] as Map<String, dynamic>,
      howManyValues: featureData["howManyValues"] as Map<String, dynamic>,
    );

    // Add reference to toolbox
    UserToolbox.addFeature(feature.name, MockDataStore.features[feature.name]!);
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

  _FeatureNodeData _createNodeDataForFeature(Feature f, Offset pos,
      {bool isFromPT = false}) {
    return _FeatureNodeData(
      position: pos,
      feature: f,
      isFromPT: isFromPT,
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
            onAcceptWithDetails: (details) async {
              final data = details.data;
              if (_currentFeatureView == null) {
                _currentFeatureView = Feature(name: "New Feature");
                widget.onFeatureStructureUpdated(_currentFeatureView!);
              }

              if (data is Feature) {
                // Load the feature from the database instead of using the dragged one
                final featureData =
                    await widget.dataInterface.getFeature(data.name);
                final feature = await _parseFeature(featureData);
                setState(() {
                  _currentFeatureView!.addComposite(feature);
                  widget.onFeatureStructureUpdated(_getRootFeature());
                  widget.onTopLevelStructureAdded(feature);
                  _displayFeature(_currentFeatureView!);
                });
              } else if (data is PerformativeTransaction) {
                // Load the feature from the database for PT as well
                final featureData =
                    await widget.dataInterface.getFeature(data.feature.name);
                final feature = await _parseFeature(featureData);
                setState(() {
                  _currentFeatureView!.addComposite(feature);
                  widget.onFeatureStructureUpdated(_getRootFeature());
                  widget.onTopLevelStructureAdded(feature, pt: data);
                  _displayFeature(_currentFeatureView!);

                  // Find and update the node after display
                  final nodeIndex = _featureNodes
                      .indexWhere((node) => node.feature.name == feature.name);
                  if (nodeIndex != -1) {
                    _featureNodes[nodeIndex].condition = data.condition;
                    _featureNodes[nodeIndex].isFromPT = true;
                  } else {
                    // If node wasn't found, add it with isFromPT = true
                    _featureNodes.add(_createNodeDataForFeature(
                      feature,
                      Offset(50 + (_featureNodes.length * 250), 100),
                      isFromPT: true,
                    ));
                  }
                });
              }
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
                    transformations: nodeData.feature.transformationsMap.values
                        .expand((x) => x)
                        .toList(),
                    condition: nodeData.condition,
                    isHovering: isHovering,
                    canAcceptHover: canAcceptHover,
                    feature: nodeData.feature,
                    parentFeature: nodeData.feature,
                    isFromPT: nodeData.isFromPT,
                    onStartingPointChanged: (subFeatureName, value) {
                      if (nodeData.isFromPT) return;
                      setState(() {
                        _currentFeatureView!
                            .setStartingPoint(subFeatureName, value);
                        widget.onFeatureStructureUpdated(_getRootFeature());
                      });
                    },
                    onHowManyChanged: (subFeatureName, value) {
                      if (nodeData.isFromPT) return;
                      setState(() {
                        _currentFeatureView!.setHowMany(subFeatureName, value);
                        widget.onFeatureStructureUpdated(_getRootFeature());
                      });
                    },
                    onRemoveFeature: () {
                      setState(() {
                        final idx = _currentFeatureView!.composites
                            .indexOf(nodeData.feature);
                        if (idx >= 0) {
                          _currentFeatureView!.composites.removeAt(idx);
                          _featureNodes.removeAt(nodeIndex);
                          widget.onFeatureStructureUpdated(_getRootFeature());
                        }
                      });
                    },
                    onRemoveCondition: () {
                      if (nodeData.isFromPT) return;
                      setState(() {
                        nodeData.condition = null;
                        widget.onFeatureStructureUpdated(_getRootFeature());
                      });
                    },
                    onTransformationRemove: (subFeatureName, transIndex) {
                      if (nodeData.isFromPT) return;
                      setState(() {
                        nodeData.feature.removeTransformationForSubFeature(
                            subFeatureName, transIndex);
                        widget.onFeatureStructureUpdated(_getRootFeature());
                        // Save the updated feature to the database
                        _registerFeatureRecursively(
                            nodeData.feature, widget.dataInterface);
                      });
                    },
                    onTransformationAdd: (subFeatureName, trans) {
                      if (nodeData.isFromPT) return;
                      setState(() {
                        nodeData.feature.addTransformationForSubFeature(
                            subFeatureName, trans);
                        widget.onFeatureStructureUpdated(_getRootFeature());
                        // Save the updated feature to the database
                        _registerFeatureRecursively(
                            nodeData.feature, widget.dataInterface);
                      });
                    },
                    onCopyFeature: (feature) async {
                      final TextEditingController nameController =
                          TextEditingController();
                      final newName = await showDialog<String>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text("Copy Feature"),
                            content: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                  labelText: 'New Feature Name'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, null),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, nameController.text),
                                child: const Text("Copy"),
                              ),
                            ],
                          );
                        },
                      );

                      if (newName != null && newName.isNotEmpty) {
                        final copiedFeature = feature.copyWithNewName(newName);

                        // First register the feature in the toolbox
                        await _registerFeatureRecursively(
                            copiedFeature, widget.dataInterface);

                        // Add to current view and notify about changes
                        setState(() {
                          _currentFeatureView!.composites.add(copiedFeature);
                          widget.onFeatureStructureUpdated(_getRootFeature());
                          widget.onTopLevelStructureAdded(copiedFeature);
                          _displayFeature(_currentFeatureView!);
                        });

                        // Show a success message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Feature "$newName" copied successfully!'),
                            ),
                          );

                          // Find and refresh the LeftSidePanel
                          final leftSidePanel = context
                              .findAncestorStateOfType<LeftSidePanelState>();
                          if (leftSidePanel != null) {
                            leftSidePanel.refreshFeatures();
                          }
                        }
                      }
                    },
                    onConditionAdd: (condition) {
                      if (nodeData.isFromPT) return;
                      setState(() {
                        nodeData.condition = condition;
                        widget.onFeatureStructureUpdated(_getRootFeature());
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

  // Add this helper method to parse feature data
  Future<Feature> _parseFeature(Map<dynamic, dynamic> data) async {
    // Parse composites
    List<Feature> compositeFeatures = [];
    for (final cName in (data["composites"] as List)) {
      final cData = await widget.dataInterface.getFeature(cName as String);
      final cFeature = await _parseFeature(cData);
      compositeFeatures.add(cFeature);
    }

    // Parse transformations
    Map<String, List<Transformation>> transformationsMap = {};
    if (data["transformations"] != null) {
      for (final t in data["transformations"] as List) {
        final tMap = t as Map<dynamic, dynamic>;
        final subFeatureName = tMap["subFeatureName"] as String;
        final transformation = Transformation(
          tMap["name"] as String,
          args: List<dynamic>.from(tMap["args"] as List),
        );

        if (!transformationsMap.containsKey(subFeatureName)) {
          transformationsMap[subFeatureName] = [];
        }
        transformationsMap[subFeatureName]!.add(transformation);
      }
    }

    // Parse starting points
    Map<String, int?> startingPoints = {};
    if (data["startingPoints"] != null) {
      final startingPointsMap = data["startingPoints"] as Map<dynamic, dynamic>;
      startingPoints = startingPointsMap
          .map((key, value) => MapEntry(key.toString(), value as int?));
    }

    // Parse howMany values
    Map<String, int?> howManyValues = {};
    if (data["howManyValues"] != null) {
      final howManyMap = data["howManyValues"] as Map<dynamic, dynamic>;
      howManyValues = howManyMap
          .map((key, value) => MapEntry(key.toString(), value as int?));
    }

    return Feature(
      name: data["name"] as String,
      composites: compositeFeatures,
      transformationsMap: transformationsMap,
      startingPoints: startingPoints,
      howManyValues: howManyValues,
      isTemplate: data["isTemplate"] as bool? ?? false,
    );
  }
}
