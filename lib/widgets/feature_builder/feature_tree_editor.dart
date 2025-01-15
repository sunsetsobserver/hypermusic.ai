import 'package:flutter/material.dart';
import '../../models/feature.dart';
import '../../models/running_instance.dart';
import '../../models/transformation.dart';
import '../../interfaces/data_interface.dart';
import 'feature_node.dart';

class FeatureTreeEditor extends StatefulWidget {
  final Feature rootFeature;
  final RunningInstance? runningInstance;
  final Function(Feature) onFeatureUpdate;
  final Function(RunningInstance)? onRunningInstanceUpdate;
  final DataInterface dataInterface;

  const FeatureTreeEditor({
    super.key,
    required this.rootFeature,
    required this.onFeatureUpdate,
    required this.dataInterface,
    this.runningInstance,
    this.onRunningInstanceUpdate,
  });

  @override
  State<FeatureTreeEditor> createState() => FeatureTreeEditorState();
}

class FeatureTreeEditorState extends State<FeatureTreeEditor> {
  final Map<String, bool> _expandedNodes = {};
  final Map<String, RunningInstance> _runningInstances = {};
  Feature? _dropTargetFeature;

  String _getFeaturePath(Feature feature, List<String> parentPath) {
    return [...parentPath, feature.name].join('/');
  }

  bool _isExpanded(String path) {
    return _expandedNodes[path] ?? false;
  }

  void _toggleExpanded(String path) {
    setState(() {
      _expandedNodes[path] = !_isExpanded(path);
    });
  }

  void _removeFeature(Feature parent, Feature featureToRemove) {
    final updatedComposites = List<Feature>.from(parent.composites)
      ..remove(featureToRemove);

    final updatedTransformationsMap =
        Map<String, List<Map<String, dynamic>>>.from(parent.transformationsMap);

    _runningInstances.remove(featureToRemove.name);

    final updatedFeature = parent.copyWith(
      composites: updatedComposites,
      transformationsMap: updatedTransformationsMap,
    );

    _updateFeatureInTree(parent, updatedFeature);
  }

  Feature? _findParentFeature(Feature root, Feature target) {
    for (final composite in root.composites) {
      if (composite == target) {
        return root;
      }
      final parent = _findParentFeature(composite, target);
      if (parent != null) {
        return parent;
      }
    }
    return null;
  }

  void _handleFeatureDrop(Feature targetFeature, Feature droppedFeature) {
    // Get the original feature's running instance from the registry
    final registryInstance = widget.dataInterface.getRunningInstanceForFeature(
      droppedFeature.name, // Original feature name
      droppedFeature.name, // Use original name as ID for initial lookup
    );

    if (registryInstance == null) {
      print(
          'Warning: No running instance found in registry for ${droppedFeature.name}');
      return;
    }

    // Use the original instance's ID if it's registered, otherwise create a new one
    final registryId = registryInstance.id.endsWith('(registered)')
        ? registryInstance.id // Preserve the original ID with its timestamp
        : '${droppedFeature.name}_${DateTime.now().millisecondsSinceEpoch}_(registered)';

    final initialInstance = RunningInstance(
      id: registryId,
      feature: registryInstance.feature.copyWith(
        name: registryId,
        composites: registryInstance.feature.composites,
        transformationsMap: registryInstance.feature.transformationsMap,
      ),
      startPoint: registryInstance.startPoint,
      howManyValues: registryInstance.howManyValues,
      transformationStartIndex: registryInstance.transformationStartIndex,
      transformationEndIndex: registryInstance.transformationEndIndex,
    );

    setState(() {
      _runningInstances[registryId] = initialInstance;
    });

    final updatedComposites = List<Feature>.from(targetFeature.composites)
      ..add(initialInstance.feature);

    final updatedTarget = targetFeature.copyWith(
      composites: updatedComposites,
    );

    _updateFeatureInTree(targetFeature, updatedTarget);
  }

  void _handleTransformationDrop(Feature targetFeature,
      Transformation transformation, String subfeatureName) {
    final transformationsMap = Map<String, List<Map<String, dynamic>>>.from(
      targetFeature.transformationsMap,
    );

    // Get the subfeature and its original name
    final subfeature =
        targetFeature.composites.firstWhere((f) => f.name == subfeatureName);
    final originalName = subfeature.name.split('_')[0];
    final originalPath = _getFeaturePath(
        Feature(
          name: originalName,
          description: subfeature.description,
          composites: subfeature.composites,
          transformationsMap: subfeature.transformationsMap,
          startPoint: subfeature.startPoint,
          howManyValues: subfeature.howManyValues,
        ),
        [targetFeature.name]);

    // Get or create transformations list using the original path
    if (!transformationsMap.containsKey(originalPath)) {
      transformationsMap[originalPath] = [];
    }

    transformationsMap[originalPath]!.add({
      'name': transformation.name,
      'args': transformation.args,
    });

    // Get the current running instance for this feature
    final parentPath = _findParentPath(widget.rootFeature, targetFeature);
    final featurePath = _getFeaturePath(targetFeature, parentPath);
    final currentInstance = _runningInstances[featurePath];
    if (currentInstance != null) {
      String newFeatureName;
      Feature updatedFeature;
      RunningInstance newInstance;

      // If this is a registered instance, create a new local one with timestamp
      if (currentInstance.id.endsWith('(registered)')) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final baseName = currentInstance.feature.name.split('_')[0];
        final localId = '${baseName}_${timestamp}_(local)';

        // Update the feature name to match the new instance ID
        newFeatureName = localId;
        updatedFeature = targetFeature.copyWith(
          name: newFeatureName,
          transformationsMap: transformationsMap,
          composites: targetFeature.composites,
        );

        newInstance = RunningInstance(
          id: localId,
          feature: updatedFeature,
          startPoint: currentInstance.startPoint,
          howManyValues: currentInstance.howManyValues,
          transformationStartIndex: currentInstance.transformationStartIndex,
          transformationEndIndex: currentInstance.transformationEndIndex,
        );

        // Calculate old and new paths
        final oldPath = featurePath;
        final newPath = _getFeaturePath(updatedFeature, parentPath);
        final wasExpanded = _expandedNodes[oldPath] ?? false;

        setState(() {
          // Remove the old instance and its expanded state
          _runningInstances.remove(featurePath);
          _expandedNodes.remove(featurePath);
          // Add the new instance with the new path
          _runningInstances[newPath] = newInstance;
          // Transfer the expansion state to the new path
          if (wasExpanded) {
            _expandedNodes[newPath] = true;
          }
        });
      } else {
        // For already local instances, just update the values without changing the path
        newFeatureName = currentInstance.id;
        updatedFeature = targetFeature.copyWith(
          name: newFeatureName,
          transformationsMap: transformationsMap,
          composites: targetFeature.composites,
        );

        newInstance = currentInstance.copyWith(
          feature: updatedFeature,
        );

        setState(() {
          _runningInstances[featurePath] = newInstance;
        });
      }

      if (widget.onRunningInstanceUpdate != null) {
        widget.onRunningInstanceUpdate!(newInstance);
      }

      // Update the feature in the tree with the new name
      _updateFeatureInTree(targetFeature, updatedFeature);
    }
  }

  void _handleFeatureChange(
    Feature parentFeature,
    String subfeatureName,
    int? transformIndex,
    String? newValue, {
    int? newStartPoint,
    int? newHowManyValues,
    bool? removeTransformation = false,
  }) {
    final transformationsMap = Map<String, List<Map<String, dynamic>>>.from(
      parentFeature.transformationsMap,
    );

    // Get the subfeature and its original name
    final subfeature =
        parentFeature.composites.firstWhere((f) => f.name == subfeatureName);
    final originalName = subfeature.name.split('_')[0];
    final originalPath = _getFeaturePath(
        Feature(
          name: originalName,
          description: subfeature.description,
          composites: subfeature.composites,
          transformationsMap: subfeature.transformationsMap,
          startPoint: subfeature.startPoint,
          howManyValues: subfeature.howManyValues,
        ),
        [parentFeature.name]);

    // Handle transformation changes if transformIndex is provided
    if (transformIndex != null) {
      final transformations = List<Map<String, dynamic>>.from(
          transformationsMap[originalPath] ?? []);
      if (transformIndex < transformations.length) {
        if (removeTransformation == true) {
          transformations.removeAt(transformIndex);
        } else if (newValue != null) {
          transformations[transformIndex] = {
            ...transformations[transformIndex],
            'args': [int.tryParse(newValue) ?? 0],
          };
        }
        transformationsMap[originalPath] = transformations;
      }
    }

    // Get the current running instance for this feature
    final parentPath = _findParentPath(widget.rootFeature, parentFeature);
    final featurePath = _getFeaturePath(parentFeature, parentPath);
    final currentInstance = _runningInstances[featurePath];
    if (currentInstance != null) {
      String newFeatureName;
      Feature updatedFeature;
      RunningInstance newInstance;

      // If this is a registered instance, create a new local one with timestamp
      if (currentInstance.id.endsWith('(registered)')) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final baseName = currentInstance.feature.name.split('_')[0];
        final localId = '${baseName}_${timestamp}_(local)';

        // Update the feature name to match the new instance ID
        newFeatureName = localId;
        updatedFeature = parentFeature.copyWith(
          name: newFeatureName,
          transformationsMap: transformationsMap,
          composites: parentFeature.composites,
        );

        newInstance = RunningInstance(
          id: localId,
          feature: updatedFeature,
          startPoint: newStartPoint ?? currentInstance.startPoint,
          howManyValues: newHowManyValues ?? currentInstance.howManyValues,
          transformationStartIndex: currentInstance.transformationStartIndex,
          transformationEndIndex: currentInstance.transformationEndIndex,
        );

        // Calculate old and new paths
        final oldPath = featurePath;
        final newPath = _getFeaturePath(updatedFeature, parentPath);
        final wasExpanded = _expandedNodes[oldPath] ?? false;

        setState(() {
          // Remove the old instance and its expanded state
          _runningInstances.remove(featurePath);
          _expandedNodes.remove(featurePath);
          // Add the new instance with the new path
          _runningInstances[newPath] = newInstance;
          // Transfer the expansion state to the new path
          if (wasExpanded) {
            _expandedNodes[newPath] = true;
          }
        });
      } else {
        // For already local instances, just update the values without changing the path
        newFeatureName = currentInstance.id;
        updatedFeature = parentFeature.copyWith(
          name: newFeatureName,
          transformationsMap: transformationsMap,
          composites: parentFeature.composites,
        );

        newInstance = currentInstance.copyWith(
          feature: updatedFeature,
          startPoint: newStartPoint ?? currentInstance.startPoint,
          howManyValues: newHowManyValues ?? currentInstance.howManyValues,
        );

        setState(() {
          _runningInstances[featurePath] = newInstance;
        });
      }

      if (widget.onRunningInstanceUpdate != null) {
        widget.onRunningInstanceUpdate!(newInstance);
      }

      // Update the feature in the tree with the new name
      _updateFeatureInTree(parentFeature, updatedFeature);
    }
  }

  void _updateRunningInstance(
      String featurePath, RunningInstance updatedInstance) {
    final currentInstance = _runningInstances[featurePath];
    if (currentInstance == null) return;

    // Find the parent feature and the feature itself
    final parentPath =
        _findParentPath(widget.rootFeature, currentInstance.feature);
    final parentFeature = _findFeatureByPath(widget.rootFeature, parentPath);
    if (parentFeature == null) return;

    _handleFeatureChange(
      parentFeature,
      currentInstance.feature.name,
      null, // no transformation index
      null, // no transformation value
      newStartPoint: updatedInstance.startPoint,
      newHowManyValues: updatedInstance.howManyValues,
    );
  }

  Feature? _findFeatureByPath(Feature root, List<String> path) {
    if (path.isEmpty) return root;

    Feature current = root;
    for (int i = 0; i < path.length; i++) {
      final composite = current.composites.firstWhere(
        (f) => f.name == path[i],
        orElse: () => current,
      );
      current = composite;
    }
    return current;
  }

  Widget _buildTransformationsList(Feature parentFeature, Feature subfeature) {
    // Get the original name for the subfeature
    final originalName = subfeature.name.split('_')[0];
    final subfeaturePath = _getFeaturePath(
        Feature(
          name: originalName,
          description: subfeature.description,
          composites: subfeature.composites,
          transformationsMap: subfeature.transformationsMap,
          startPoint: subfeature.startPoint,
          howManyValues: subfeature.howManyValues,
        ),
        [parentFeature.name]);
    final transformations =
        parentFeature.transformationsMap[subfeaturePath] ?? [];

    return DragTarget<Transformation>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => _handleTransformationDrop(
          parentFeature, details.data, subfeature.name),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovering
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.2),
              width: isHovering ? 1 : 0.5,
            ),
            borderRadius: BorderRadius.circular(2),
            color: isHovering
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '$originalName:', // Use original name in display
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (transformations.isEmpty)
                const Text(
                  'Drop transformations here',
                  style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic),
                )
              else
                StatefulBuilder(
                  builder: (context, setState) {
                    final scrollController = ScrollController();

                    void scrollLeft() {
                      if (scrollController.position.pixels > 0) {
                        scrollController.animateTo(
                          scrollController.position.pixels - 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      }
                    }

                    void scrollRight() {
                      if (scrollController.position.pixels <
                          scrollController.position.maxScrollExtent) {
                        scrollController.animateTo(
                          scrollController.position.pixels + 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      }
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 12,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          icon: const Icon(Icons.chevron_left),
                          onPressed: scrollLeft,
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < transformations.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 2),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          transformations[i]['name']
                                                  as String? ??
                                              '',
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          width: 32,
                                          height: 16,
                                          child: TextFormField(
                                            initialValue: (transformations[i]
                                                            ['args'] as List?)
                                                        ?.isNotEmpty ==
                                                    true
                                                ? transformations[i]['args'][0]
                                                    .toString()
                                                : '0',
                                            style: const TextStyle(fontSize: 9),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                      vertical: 1),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(2)),
                                              ),
                                            ),
                                            onChanged: (value) =>
                                                _handleFeatureChange(
                                              parentFeature,
                                              subfeature.name,
                                              i,
                                              value,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => _handleFeatureChange(
                                              parentFeature,
                                              subfeature.name,
                                              i,
                                              null,
                                              removeTransformation: true,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: 12,
                                              color:
                                                  Colors.grey.withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          iconSize: 12,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          icon: const Icon(Icons.chevron_right),
                          onPressed: scrollRight,
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _updateFeatureInTree(Feature oldFeature, Feature newFeature) {
    // Store the expanded state before the update
    final expandedState = Map<String, bool>.from(_expandedNodes);

    if (oldFeature == widget.rootFeature) {
      widget.onFeatureUpdate(newFeature);
    } else {
      final updatedRoot =
          _updateFeatureInSubtree(widget.rootFeature, oldFeature, newFeature);
      widget.onFeatureUpdate(updatedRoot);
    }

    // Restore the expanded state after the update
    setState(() {
      _expandedNodes.addAll(expandedState);
    });
  }

  Feature _updateFeatureInSubtree(
      Feature current, Feature target, Feature replacement) {
    if (current == target) {
      return replacement;
    }

    final updatedComposites = current.composites.map((composite) {
      return _updateFeatureInSubtree(composite, target, replacement);
    }).toList();

    return current.copyWith(composites: updatedComposites);
  }

  RunningInstance _getOrCreateRunningInstance(
      String featurePath, Feature feature) {
    if (_runningInstances.containsKey(featurePath)) {
      return _runningInstances[featurePath]!;
    }

    final instance = RunningInstance(
      id: featurePath,
      feature: feature,
      startPoint: feature.startPoint,
      howManyValues: feature.howManyValues,
      transformationStartIndex: 0,
      transformationEndIndex: feature.howManyValues - 1,
    );

    setState(() {
      _runningInstances[featurePath] = instance;
    });
    return instance;
  }

  // Helper method to compare transformation maps
  bool _areTransformationsEqual(
    Map<String, List<Map<String, dynamic>>> map1,
    Map<String, List<Map<String, dynamic>>> map2,
  ) {
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final list1 = map1[key]!;
      final list2 = map2[key]!;
      if (list1.length != list2.length) return false;

      for (var i = 0; i < list1.length; i++) {
        if (list1[i]['name'] != list2[i]['name']) return false;
        if (!_areListsEqual(
            list1[i]['args'] as List, list2[i]['args'] as List)) {
          return false;
        }
      }
    }
    return true;
  }

  bool _areListsEqual(List list1, List list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Widget _buildFeatureNode(Feature feature, List<String> parentPath,
      {bool isRoot = false}) {
    final featurePath = _getFeaturePath(feature, parentPath);
    final runningInstance = _getOrCreateRunningInstance(featurePath, feature);
    final hasComposites = feature.composites.isNotEmpty;
    final isExpanded = _isExpanded(featurePath);
    final isDropTarget = _dropTargetFeature == feature;
    final isComposite = !runningInstance.feature.isScalar || isRoot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            DragTarget<Feature>(
              onWillAcceptWithDetails: (details) => isComposite,
              onAcceptWithDetails: (details) =>
                  _handleFeatureDrop(feature, details.data),
              onMove: (_) => setState(
                  () => isComposite ? _dropTargetFeature = feature : null),
              onLeave: (_) => setState(() => _dropTargetFeature = null),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    border: isDropTarget && isComposite
                        ? Border.all(
                            color: Theme.of(context).primaryColor, width: 1)
                        : null,
                    borderRadius: BorderRadius.circular(2),
                    color: isComposite ? Colors.grey.withOpacity(0.05) : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasComposites || isRoot) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: IconButton(
                            iconSize: 10,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            icon: Icon(
                              isExpanded
                                  ? Icons.expand_more
                                  : Icons.chevron_right,
                              size: 10,
                            ),
                            onPressed: () => _toggleExpanded(featurePath),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: FeatureNode(
                          instance: runningInstance,
                          onUpdate: (instance,
                              {int? startPoint, int? howManyValues}) {
                            if (startPoint != null || howManyValues != null) {
                              _handleFeatureChange(
                                instance.feature,
                                instance.feature.name,
                                null, // no transformation index
                                null, // no transformation value
                                newStartPoint: startPoint,
                                newHowManyValues: howManyValues,
                              );
                              return;
                            }
                            _updateRunningInstance(featurePath, instance);
                          },
                          onRemove: isRoot
                              ? null
                              : () {
                                  final parent = _findParentFeature(
                                      widget.rootFeature, feature);
                                  if (parent != null) {
                                    setState(() {
                                      _runningInstances.remove(featurePath);
                                    });
                                    _removeFeature(parent, feature);
                                  }
                                },
                          isExpanded: isExpanded,
                          onToggleExpand: hasComposites
                              ? () => _toggleExpanded(featurePath)
                              : () {},
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        if (isExpanded && hasComposites)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasComposites) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final composite in feature.composites)
                          _buildTransformationsList(feature, composite),
                      ],
                    ),
                  ),
                ],
                for (final composite in feature.composites)
                  _buildFeatureNode(composite, [featurePath]),
              ],
            ),
          ),
      ],
    );
  }

  List<RunningInstance> collectRunningInstances(
      Feature feature, List<String> parentPath) {
    final instances = <RunningInstance>[];
    final featurePath = _getFeaturePath(feature, parentPath);

    // Add this feature's running instance if it exists
    if (_runningInstances.containsKey(featurePath)) {
      final instance = _runningInstances[featurePath]!;

      // If the instance is marked as (registered), try to get the original from registry
      if (instance.id.endsWith('(registered)')) {
        final originalName = instance.feature.name.split('_')[0];
        final registryInstance =
            widget.dataInterface.getRunningInstanceForFeature(
          originalName,
          originalName,
        );
        if (registryInstance != null) {
          // Use the registry instance since it hasn't been modified
          instances.add(registryInstance);
        } else {
          // Fallback to the current instance if registry instance not found
          instances.add(instance);
        }
      } else {
        // This is a local instance, use it as is
        instances.add(instance);
      }
    }

    // Recursively collect instances for composites
    for (final composite in feature.composites) {
      instances.addAll(
          collectRunningInstances(composite, [...parentPath, feature.name]));
    }

    return instances;
  }

  // Helper method to find the full path to a feature
  List<String> _findParentPath(Feature root, Feature target,
      [List<String> currentPath = const []]) {
    if (root == target) {
      return currentPath;
    }

    for (final composite in root.composites) {
      final path =
          _findParentPath(composite, target, [...currentPath, root.name]);
      if (path.isNotEmpty) {
        return path;
      }
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: _buildFeatureNode(widget.rootFeature, [], isRoot: true),
      ),
    );
  }
}
