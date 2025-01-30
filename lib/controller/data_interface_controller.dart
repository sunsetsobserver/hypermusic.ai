import 'package:crypto/crypto.dart';

// Models
import 'package:hypermusic/model/feature.dart';
import 'package:hypermusic/model/running_instance.dart';

abstract class DataInterfaceController
{
  /// will return registered feature version
  Future<Digest?> registerFeature(Feature feature);
  /// will return newest feature version
  Feature? getNewestFeature(String featureName);
  ///will return all feature versions for given name
  List<Feature> getFeatures(String featureName);
  /// will return feature with specyfic version
  Feature? getFeature(String featureName, Digest featureVersion);
  /// will remove feature with specyfic version
  bool removeFeature(String featureName, Digest featureVersion);
  ///will remove all feature versions for given name
  bool removeFeatures(String featureName);
  /// will return all feature names
  Future<List<String>> getAllFeatureNames();
  /// will return all feature versions
  Future<List<Digest>> getAllFeatureVersions(String featureName);

  /// will return registered RI version
  Future<Digest?> registerRunningInstance(String featureName, Digest featureVersion, RunningInstance instance);
  /// will return newest RI version, for given feature with version
  RunningInstance? getNewestRunningInstance(String featureName, Digest featureVersion);
  ///will return all RI version versions, for given feature with version
  List<RunningInstance> getRunningInstances(String featureName, Digest featureVersion);
  /// will return RI with specyfic version, for given feature with version
  RunningInstance? getRunningInstance(String featureName, Digest featureVersion, Digest riVersion);
  /// will remove RI with specyfic version, for given feature with version
  bool removeRunningInstance(String featureName, Digest featureVersion, Digest riVersion);
  ///will remove all RI versions for given feature with version
  bool removeRunningInstances(String featureName, Digest featureVersion);
  /// will return all RI versions, for given feature with version
  Future<List<Digest>> getAllRunningInstances(String featureName, Digest featureVersion);

  // TODO implement
  Future<List<String>> getAllConditions();
  Future<List<String>> getAllTransformations();
}
