import '../interfaces/data_interface.dart';
import '../models/feature.dart';
import '../models/running_instance.dart';

class Registry implements DataInterface {
  final Map<String, Feature> _features = {};
  final Map<String, Map<String, RunningInstance>> _runningInstances = {};
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
      for (final instance in runningInstances) {
        addRunningInstance(instance);
      }
    }

    final feature = Feature(
      name: name,
      description: "Generated feature",
      composites: composites.map((c) {
        final runningInstance = runningInstances?.firstWhere(
          (ri) => ri.id.split('_').first == c,
          orElse: () => throw UnimplementedError(),
        );
        return runningInstance?.feature ?? _features[c]!;
      }).toList(),
      transformationsMap: _groupTransformationsBySubFeature(transformations),
    );

    _features[name] = feature;
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
    final featureName = instance.feature.name;
    _runningInstances.putIfAbsent(featureName, () => {});
    _runningInstances[featureName]![instanceName] = instance;
  }

  @override
  void removeRunningInstance(RunningInstance instance) {
    final instanceName = instance.id;
    final featureName = instance.feature.name;
    _runningInstances[featureName]?.remove(instanceName);
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
}
