// lib/interfaces/data_interface.dart

import '../models/feature.dart';
import '../models/running_instance.dart';

abstract class DataInterface {
  Future<void> registerFeature(String name, List<String> composites,
      List<Map<String, dynamic>> transformations,
      {List<RunningInstance>? runningInstances});

  void addRunningInstance(RunningInstance instance);
  void removeRunningInstance(RunningInstance instance);
  void updateRunningInstance(
      RunningInstance oldInstance, RunningInstance newInstance);
  Feature? getFeature(String name);

  Future<List<String>> getAllFeatures();
  Future<List<String>> getAllConditions();
  Future<List<String>> getAllTransformations();
  List<Feature> get features;
  List<RunningInstance> get runningInstances;
}
