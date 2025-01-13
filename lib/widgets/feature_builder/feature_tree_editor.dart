import 'package:flutter/material.dart';
import '../../models/feature.dart';
import '../../models/running_instance.dart';
import '../../models/transformation.dart';
import 'feature_node.dart';

class FeatureTreeEditor extends StatefulWidget {
  final Feature rootFeature;
  final RunningInstance? runningInstance;
  final Function(Feature) onFeatureUpdate;
  final Function(RunningInstance)? onRunningInstanceUpdate;

  const FeatureTreeEditor({
    super.key,
    required this.rootFeature,
    required this.onFeatureUpdate,
    this.runningInstance,
    this.onRunningInstanceUpdate,
  });

  @override
  State<FeatureTreeEditor> createState() => _FeatureTreeEditorState();
}

class _FeatureTreeEditorState extends State<FeatureTreeEditor> {
  final Map<String, bool> _expandedNodes = {};
  Feature? _dropTargetFeature;
  String? _selectedSubfeatureForTransformation;

  String _getFeaturePath(Feature feature, List<String> parentPath) {
    final currentPath = [...parentPath, feature.name];
    return currentPath.join('/');
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

    final featurePath = _getFeaturePath(featureToRemove, [parent.name]);
    updatedTransformationsMap.remove(featurePath);

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
    final uniqueDroppedFeature = droppedFeature.copyWith(
      name: '${droppedFeature.name}_${DateTime.now().millisecondsSinceEpoch}',
    );

    final updatedComposites = List<Feature>.from(targetFeature.composites)
      ..add(uniqueDroppedFeature);

    final updatedTransformationsMap =
        Map<String, List<Map<String, dynamic>>>.from(
            targetFeature.transformationsMap);

    for (final composite in uniqueDroppedFeature.composites) {
      final newPath = '${uniqueDroppedFeature.name}/${composite.name}';
      final originalPath = '${droppedFeature.name}/${composite.name}';

      if (droppedFeature.transformationsMap.containsKey(originalPath)) {
        updatedTransformationsMap[newPath] = List<Map<String, dynamic>>.from(
            droppedFeature.transformationsMap[originalPath]!);
      }
    }

    final updatedTarget = targetFeature.copyWith(
      composites: updatedComposites,
      transformationsMap: updatedTransformationsMap,
    );

    _updateFeatureInTree(targetFeature, updatedTarget);
  }

  void _handleTransformationDrop(Feature targetFeature,
      Transformation transformation, String subfeatureName) {
    final transformationsMap = Map<String, List<Map<String, dynamic>>>.from(
      targetFeature.transformationsMap,
    );

    final subfeaturePath = _getFeaturePath(
        targetFeature.composites.firstWhere((f) => f.name == subfeatureName),
        [targetFeature.name]);

    if (!transformationsMap.containsKey(subfeaturePath)) {
      transformationsMap[subfeaturePath] = [];
    }

    transformationsMap[subfeaturePath]!.add({
      'name': transformation.name,
      'args': transformation.args,
    });

    final updatedFeature = targetFeature.copyWith(
      transformationsMap: transformationsMap,
    );

    _updateFeatureInTree(targetFeature, updatedFeature);
  }

  void _handleTransformationArgumentChange(Feature parentFeature,
      String subfeatureName, int transformIndex, String newValue) {
    final transformationsMap = Map<String, List<Map<String, dynamic>>>.from(
      parentFeature.transformationsMap,
    );

    final subfeaturePath = _getFeaturePath(
        parentFeature.composites.firstWhere((f) => f.name == subfeatureName),
        [parentFeature.name]);

    final transformations = List<Map<String, dynamic>>.from(
        transformationsMap[subfeaturePath] ?? []);
    if (transformIndex < transformations.length) {
      transformations[transformIndex] = {
        ...transformations[transformIndex],
        'args': [int.tryParse(newValue) ?? 0],
      };
      transformationsMap[subfeaturePath] = transformations;

      final updatedFeature = parentFeature.copyWith(
        transformationsMap: transformationsMap,
      );

      _updateFeatureInTree(parentFeature, updatedFeature);
    }
  }

  void _handleTransformationRemove(
      Feature parentFeature, String subfeatureName, int transformIndex) {
    final transformationsMap = Map<String, List<Map<String, dynamic>>>.from(
      parentFeature.transformationsMap,
    );

    final subfeaturePath = _getFeaturePath(
        parentFeature.composites.firstWhere((f) => f.name == subfeatureName),
        [parentFeature.name]);

    final transformations = List<Map<String, dynamic>>.from(
        transformationsMap[subfeaturePath] ?? []);
    if (transformIndex < transformations.length) {
      transformations.removeAt(transformIndex);
      transformationsMap[subfeaturePath] = transformations;

      final updatedFeature = parentFeature.copyWith(
        transformationsMap: transformationsMap,
      );

      _updateFeatureInTree(parentFeature, updatedFeature);
    }
  }

  Widget _buildTransformationsList(Feature parentFeature, Feature subfeature) {
    final subfeaturePath = _getFeaturePath(subfeature, [parentFeature.name]);
    final transformations =
        parentFeature.transformationsMap[subfeaturePath] ?? [];

    return DragTarget<Transformation>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => _handleTransformationDrop(
          parentFeature, details.data, subfeature.name),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovering
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.3),
              width: isHovering ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
            color: isHovering
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transformations for ${subfeature.name}:',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (transformations.isEmpty)
                const Text(
                  'Drop transformations here',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < transformations.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              transformations[i]['name'] as String? ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              height: 24,
                              child: TextFormField(
                                initialValue: (transformations[i]['args']
                                                as List?)
                                            ?.isNotEmpty ==
                                        true
                                    ? transformations[i]['args'][0].toString()
                                    : '0',
                                style: const TextStyle(fontSize: 12),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) =>
                                    _handleTransformationArgumentChange(
                                  parentFeature,
                                  subfeature.name,
                                  i,
                                  value,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _handleTransformationRemove(
                                  parentFeature,
                                  subfeature.name,
                                  i,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _updateFeatureInTree(Feature oldFeature, Feature newFeature) {
    if (oldFeature == widget.rootFeature) {
      widget.onFeatureUpdate(newFeature);
    } else {
      final parent = _findParentFeature(widget.rootFeature, oldFeature);
      if (parent != null) {
        final parentComposites = List<Feature>.from(parent.composites);
        final targetIndex = parentComposites.indexOf(oldFeature);
        parentComposites[targetIndex] = newFeature;

        final updatedParent = parent.copyWith(composites: parentComposites);

        if (parent == widget.rootFeature) {
          widget.onFeatureUpdate(updatedParent);
        } else {
          final grandParent = _findParentFeature(widget.rootFeature, parent);
          if (grandParent != null) {
            final grandParentComposites =
                List<Feature>.from(grandParent.composites);
            final parentIndex = grandParentComposites.indexOf(parent);
            grandParentComposites[parentIndex] = updatedParent;
            widget.onFeatureUpdate(
                grandParent.copyWith(composites: grandParentComposites));
          }
        }
      }
    }
  }

  Widget _buildFeatureNode(Feature feature, List<String> parentPath,
      {bool isRoot = false}) {
    final featurePath = _getFeaturePath(feature, parentPath);
    final hasComposites = feature.composites.isNotEmpty;
    final isExpanded = _isExpanded(featurePath);
    final isDropTarget = _dropTargetFeature == feature;
    final isComposite = !feature.isScalar || isRoot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: Theme.of(context).primaryColor, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(4),
                    color: isComposite ? Colors.grey.withOpacity(0.05) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FeatureNode(
                              instance: RunningInstance(
                                id: featurePath,
                                feature: feature,
                                startPoint: 0,
                                howManyValues: 10,
                                transformationStartIndex: 0,
                                transformationEndIndex: 10,
                              ),
                              onUpdate: (updatedInstance) {
                                _updateFeatureInTree(
                                    feature, updatedInstance.feature);
                              },
                              onRemove: isRoot
                                  ? null
                                  : () {
                                      final parent = _findParentFeature(
                                          widget.rootFeature, feature);
                                      if (parent != null) {
                                        _removeFeature(parent, feature);
                                      }
                                    },
                              isExpanded: isExpanded,
                              onToggleExpand: hasComposites
                                  ? () => _toggleExpanded(featurePath)
                                  : () {},
                            ),
                          ),
                          if (isComposite && !isRoot) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.folder_outlined,
                                size: 16,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ],
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
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasComposites) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildFeatureNode(widget.rootFeature, [], isRoot: true),
      ),
    );
  }
}
