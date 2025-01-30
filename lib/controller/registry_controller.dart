import 'dart:convert'; // For utf8 encoding
import 'package:crypto/crypto.dart'; // For hashing

// Models
import 'package:hypermusic/model/feature.dart';
import 'package:hypermusic/model/running_instance.dart';

// Constrollers
import 'package:hypermusic/controller/data_interface_controller.dart';

Digest sha256FromString(String input) => sha256.convert(utf8.encode(input));

class RegistryController implements DataInterfaceController 
{
  // [featureName] = featureVersion
  final Map<String, Digest> _newestFeatureVersion = {};
  // [featureName][featureVersion] = Feature
  final Map<String, Map<Digest, Feature>> _features = {};

  // [featureName][featureVersion] = riVersion
  final Map<String, Map<Digest, Digest>> _newestrunningInstance = {};
  // [featureName][featureVersion][riVersion]
  final Map<String, Map<Digest, Map<Digest,RunningInstance>>> _runningInstances = {};


  @override
  Future<Digest?> registerFeature(Feature feature) async
  {
    // construct new bucket
    if(_features.containsKey(feature.name) == false)
    {
      _features[feature.name] = {};
      _newestrunningInstance[feature.name] = {};
      _runningInstances[feature.name] = {};
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final registrationId = sha256FromString('${feature.name}_$timestamp');

    assert(_features[feature.name]!.containsKey(registrationId), "already contains this version");
    if(_features[feature.name]!.containsKey(registrationId))return null;
    
    _features[feature.name]![registrationId] = feature;
    _newestFeatureVersion[feature.name] = registrationId;

    // construct empty map for running instances
    _runningInstances[feature.name]![registrationId] = {};

    return registrationId;
  }

  @override
  Feature? getNewestFeature(String featureName)
  {
      return _features[featureName]?[_newestFeatureVersion[featureName]];
  }

  @override
  List<Feature> getFeatures(String featureName)
  {
    return _features[featureName]!.values.toList();
  }

  @override
  Feature? getFeature(String featureName, Digest featureVersion)
  {
    return _features[featureName]?[featureVersion];
  }

  @override
  bool removeFeature(String featureName, Digest featureVersion)
  {
    if(_features.containsKey(featureName) == false)return false;
    return _features[featureName]!.remove(featureVersion) != null;
  }

  @override
  bool removeFeatures(String featureName)
  {
    if(_features.containsKey(featureName) == false)return false;
    return _features.remove(featureName) != null;
  }

  @override
  Future<List<String>> getAllFeatureNames() async
  {
    return _features.keys.toList();
  }

  @override
  Future<List<Digest>> getAllFeatureVersions(String featureName) async
  {
    if(_features.containsKey(featureName) == false)return [];
    return _features[featureName]!.keys.toList();
  }

  @override
  Future<Digest?> registerRunningInstance(String featureName, Digest featureVersion, RunningInstance instance)async
  {
    // bucket not exists
    if(_features.containsKey(featureName) == false)return null;
    if(_runningInstances.containsKey(featureName) == false)return null;
    if(_newestrunningInstance.containsKey(featureName) == false)return null;
    if(_runningInstances[featureName]!.containsKey(featureVersion) == false)return null;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final registrationId = sha256FromString('${featureName}_${featureVersion}_$timestamp');

    assert(_runningInstances[featureName]![featureVersion]!.containsKey(registrationId), "already contains this version");
    if(_runningInstances[featureName]![featureVersion]!.containsKey(registrationId))return null;

    _runningInstances[featureName]![featureVersion]![registrationId] = instance;
    _newestrunningInstance[featureName]![featureVersion] = registrationId;

    return registrationId;
  }

  @override
  RunningInstance? getNewestRunningInstance(String featureName, Digest featureVersion)
  {
    if(_features.containsKey(featureName) == false)return null;
    if(_runningInstances.containsKey(featureName) == false)return null;
    if(_newestrunningInstance.containsKey(featureName) == false)return null;
    if(_runningInstances[featureName]!.containsKey(featureVersion) == false)return null;
    return _runningInstances[featureName]![featureVersion]![_newestrunningInstance[featureName]![featureVersion]];
  }

  @override
  List<RunningInstance> getRunningInstances(String featureName, Digest featureVersion)
  {
    if(_features.containsKey(featureName) == false)return [];
    if(_runningInstances.containsKey(featureName) == false)return [];
    if(_runningInstances[featureName]!.containsKey(featureVersion) == false)return [];
    return _runningInstances[featureName]![featureVersion]!.values.toList();
  }

  @override
  RunningInstance? getRunningInstance(String featureName, Digest featureVersion, Digest riVersion)
  {
    if(_features.containsKey(featureName) == false)return null;
    if(_runningInstances.containsKey(featureName) == false)return null;
    if(_runningInstances[featureName]!.containsKey(featureVersion) == false)return null;
    return _runningInstances[featureName]![featureVersion]![riVersion];
  }

  @override
  bool removeRunningInstance(String featureName, Digest featureVersion, Digest riVersion)
  {
    if(_features.containsKey(featureName) == false)return false;
    if(_runningInstances.containsKey(featureName) == false)return false;
    if(_runningInstances[featureName]!.containsKey(featureVersion) == false)return false;
    return _runningInstances[featureName]![featureVersion]!.remove(riVersion) != null;
  }

  @override
  bool removeRunningInstances(String featureName, Digest featureVersion)
  {
    if(_features.containsKey(featureName) == false)return false;
    if(_runningInstances.containsKey(featureName) == false)return false;
    return _runningInstances[featureName]!.remove(featureVersion) != null;
  }

  @override
  Future<List<Digest>> getAllRunningInstances(String featureName, Digest featureVersion) async
  {
    if(_features.containsKey(featureName) == false)return [];
    if(_runningInstances.containsKey(featureName) == false)return [];
    if(_runningInstances[featureName]!.containsKey(featureVersion) == false)return [];
    return _runningInstances[featureName]![featureVersion]!.keys.toList();
  }




  //TODO implement Conditions
  @override
  Future<List<String>> getAllConditions() async {
    return ['true', 'false', 'Counter']; // Default conditions
  }

  //TODO implement Transformations
  @override
  Future<List<String>> getAllTransformations() async {
    return ['Add', 'Mul', 'Nop']; // Default transformations
  }
}
