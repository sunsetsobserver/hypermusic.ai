import '../interfaces/data_interface.dart';
import '../models/feature.dart';
import '../models/running_instance.dart';

class Registry implements DataInterface {
  final Map<String, Feature> _features = {};
  final Map<String, Map<String, RunningInstance>> _runningInstances = {};
  final Map<String, Map<String, String>> _featureToInstanceIds = {};
  bool _isInitialized = false;

  @override
  List<Feature> get features => _features.values.toList();

  @override
  List<RunningInstance> get runningInstances =>
      _runningInstances.values.expand((map) => map.values).toList();

  bool get isInitialized => _isInitialized;

  void ensureInitialized() {
    _isInitialized = true;
  }

  bool containsFeature(String name) {
    return _features.containsKey(name);
  }

  bool containsRunningInstance(String featureName, String instanceName) {
    return _runningInstances[featureName]?.containsKey(instanceName) ?? false;
  }

  Feature? getFeatureAt(String name) {
    return _features[name];
  }

  RunningInstance? getRunningInstance(String featureName, String instanceName) {
    return _runningInstances[featureName]?[instanceName];
  }

  @override
  Future<List<String>> getAllFeatures() async {
    return _features.keys.toList();
  }

  @override
  Future<List<String>> getAllConditions() async {
    return ['true', 'false', 'Counter']; // Default conditions
  }

  @override
  Future<List<String>> getAllTransformations() async {
    return ['Add', 'Mul', 'Nop']; // Default transformations
  }

  @override
  Future<void> registerFeature(String name, List<String> composites,
      List<Map<String, dynamic>> transformations,
      {List<RunningInstance>? runningInstances}) async {
    if (runningInstances != null) {
      _featureToInstanceIds.putIfAbsent(name, () => {});

      for (final instance in runningInstances) {
        final originalFeatureName = instance.feature.name.split('_')[0];

        // For unmodified instances, just reference their existing registry ID
        if (instance.id.endsWith('(registered)')) {
          _featureToInstanceIds[name]![originalFeatureName] = instance.id;
          continue;
        }

        // For local instances, preserve their timestamp and just change status to registered
        final newRegistryId = instance.id.endsWith('(local)')
            ? instance.id.replaceAll('(local)', '(registered)')
            : '${originalFeatureName}_${DateTime.now().millisecondsSinceEpoch}_(registered)';

        final registeredInstance = RunningInstance(
          id: newRegistryId,
          feature: instance.feature.copyWith(
            name: newRegistryId,
            composites: instance.feature.composites,
            transformationsMap: instance.feature.transformationsMap,
          ),
          startPoint: instance.startPoint,
          howManyValues: instance.howManyValues,
          transformationStartIndex: instance.transformationStartIndex,
          transformationEndIndex: instance.transformationEndIndex,
        );

        // Store in registry
        _runningInstances.putIfAbsent(originalFeatureName, () => {});
        _runningInstances[originalFeatureName]![newRegistryId] =
            registeredInstance;

        // Map to the new registry ID
        _featureToInstanceIds[name]![originalFeatureName] = newRegistryId;
      }
    }

    // Create the feature using the stored running instances
    final feature = Feature(
      name: name,
      description: "Generated feature",
      composites: composites.map((c) {
        // Get the running instance ID for this composite
        final instanceId = _featureToInstanceIds[name]?[c];
        if (instanceId != null) {
          // Get the running instance from the registry
          final instance = _runningInstances[c]?[instanceId];
          if (instance != null) {
            // If this is a registered instance, use its feature and preserve the instance ID
            if (instance.id.endsWith('(registered)')) {
              return instance.feature.copyWith(
                  name: instance
                      .id // Store the full instance ID to preserve timestamp
                  );
            }
            // Otherwise create a new feature with the running instance's values
            return instance.feature.copyWith(
              name: instance.id, // Store the new instance ID
              startPoint: instance.startPoint,
              howManyValues: instance.howManyValues,
              composites: instance.feature.composites,
              transformationsMap: instance.feature.transformationsMap,
            );
          }
        }
        // If no running instance found, use the original feature
        return _features[c]!;
      }).toList(),
      transformationsMap: _groupTransformationsBySubFeature(transformations),
      startPoint: runningInstances
              ?.firstWhere(
                (ri) => ri.feature.name.split('_')[0] == name,
                orElse: () => runningInstances.first,
              )
              .startPoint ??
          0,
      howManyValues: runningInstances
              ?.firstWhere(
                (ri) => ri.feature.name.split('_')[0] == name,
                orElse: () => runningInstances.first,
              )
              .howManyValues ??
          10,
    );

    _features[name] = feature;

    // Add a running instance for the newly created feature
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newFeatureId = '${name}_${timestamp}_(registered)';

    // Create a new feature that preserves the complete structure
    final newFeature = feature.copyWith(
      name: newFeatureId,
      composites: feature.composites, // Explicitly preserve composites
      transformationsMap:
          feature.transformationsMap, // Explicitly preserve transformations
      startPoint: feature.startPoint,
      howManyValues: feature.howManyValues,
    );

    final newRunningInstance = RunningInstance(
      id: newFeatureId,
      feature: newFeature,
      startPoint: feature.startPoint,
      howManyValues: feature.howManyValues,
      transformationStartIndex: 0,
      transformationEndIndex: feature.howManyValues - 1,
    );
    addRunningInstance(newRunningInstance);
  }

  Map<String, List<Map<String, dynamic>>> _groupTransformationsBySubFeature(
      List<Map<String, dynamic>> transformations) {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final trans in transformations) {
      final subFeatureName = trans['subFeatureName'] as String;
      result.putIfAbsent(subFeatureName, () => []).add(trans);
    }
    return result;
  }

  @override
  void addRunningInstance(RunningInstance instance) {
    final instanceName = instance.id;
    final featureName = instance.feature.name.split('_').first;
    _runningInstances.putIfAbsent(featureName, () => {});
    _runningInstances[featureName]![instanceName] = instance;
  }

  @override
  void removeRunningInstance(RunningInstance instance) {
    final instanceName = instance.id;
    final featureName = instance.feature.name;
    _runningInstances[featureName]?.remove(instanceName);

    // Also clean up the mapping
    for (final entry in _featureToInstanceIds.entries) {
      entry.value.removeWhere((_, id) => id == instanceName);
    }
  }

  @override
  void updateRunningInstance(
      RunningInstance oldInstance, RunningInstance newInstance) {
    removeRunningInstance(oldInstance);
    addRunningInstance(newInstance);
  }

  @override
  Feature? getFeature(String name) => _features[name];

  void addFeature(Feature feature) {
    _features[feature.name] = feature;
  }

  void addTransformation(
      String name, List<Map<String, dynamic>> transformations) {
    final feature = _features[name];
    if (feature != null) {
      final newTransformationsMap =
          Map<String, List<Map<String, dynamic>>>.from(
              feature.transformationsMap);
      for (final trans in transformations) {
        final subFeatureName = trans['subFeatureName'] as String;
        newTransformationsMap.putIfAbsent(subFeatureName, () => []).add(trans);
      }
      _features[name] =
          feature.copyWith(transformationsMap: newTransformationsMap);
    }
  }

  int getRunningInstancesCount(String featureName) {
    return _runningInstances[featureName]?.length ?? 0;
  }

  @override
  RunningInstance? getRunningInstanceForFeature(
      String featureName, String subFeatureName) {
    // First try to find by exact ID
    for (final instances in _runningInstances.values) {
      for (final instance in instances.values) {
        if (instance.id == subFeatureName) {
          return instance;
        }
      }
    }

    // Try to find the mapped instance ID for this feature
    final originalName = subFeatureName.split('_').first;
    final mappedId = _featureToInstanceIds[featureName]?[originalName];
    if (mappedId != null) {
      // Get the instance using the mapped ID
      final instance = _runningInstances[originalName]?[mappedId];
      if (instance != null) {
        return instance;
      }
    }

    // If no mapped ID found, fall back to the most recent instance
    if (_runningInstances.containsKey(originalName)) {
      final instances = _runningInstances[originalName]!.values.toList();
      if (instances.isNotEmpty) {
        instances.sort((a, b) => b.id.compareTo(a.id));
        return instances.first;
      }
    }

    return null;
  }
}
