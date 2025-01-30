import 'model/feature.dart';
import 'model/running_instance.dart';
import 'package:hypermusic/controller/data_interface_controller.dart';

class RegistryInitializer {
  static Future<bool> initialize(DataInterfaceController registry) async
  {
    // Register scalar features

    // Register Pitch
    final pitchVer = await registry.registerFeature(
      Feature(
        name: "Pitch",
        description: "A scalar feature representing pitch",
        composites: [],
        transformationsMap: {},
    ));
    if(pitchVer == null){
      assert(false, "Failed to register Pitch feature");
      return false;
    }
    // Register Pitch running instance
    registry.registerRunningInstance('Pitch', pitchVer, 
      RunningInstance(
        startPoint: 60,
        howManyValues: 12,
        transformationStartIndex: 0,
        transformationEndIndex: 0,
    ));

    // Register Time
    final timeVer = await registry.registerFeature(
      Feature(
        name: "Time",
        description: "A scalar feature representing time",
        composites: [],
        transformationsMap: {},
    ));
    if(timeVer == null){
      assert(false, "Failed to register Time feature");
      return false;
    }
    // Register Time running instance
    registry.registerRunningInstance('Time', timeVer, 
    RunningInstance(
      startPoint: 60,
      howManyValues: 12,
      transformationStartIndex: 0,
      transformationEndIndex: 0,
    ));

    // Register Duration
    final durationVer = await registry.registerFeature(
      Feature(
        name: "Duration",
        description: "A scalar feature representing duration",
        composites: [],
        transformationsMap: {},
    ));
    if(durationVer == null){
      assert(false, "Failed to register Duration feature");
      return false;
    }
    // Register Duration running instance
    registry.registerRunningInstance('Duration', durationVer, 
      RunningInstance(
        startPoint: 0,
        howManyValues: 8,
        transformationStartIndex: 0,
        transformationEndIndex: 0,
    ));

    // Register composite features

    // Register FeatureA
    final featureAVer = await registry.registerFeature(
      Feature(
        name: "FeatureA",
        description: "A composite feature combining Pitch and Time",
        composites: [
            registry.getFeature("Pitch", pitchVer)!,
            registry.getFeature("Time", timeVer)!,
        ],
        transformationsMap: {
          'FeatureA/Pitch': [
            {
              'name': 'Add',
              'args': [3],
            },
            {
              'name': 'Mul',
              'args': [2],
            },
            {
              'name': 'Nop',
              'args': [],
            },
            {
              'name': 'Add',
              'args': [1]
            },
          ],
          'FeatureA/Time': [
            {
              'name': 'Add',
              'args': [1],
            },
            {
              'name': 'Add',
              'args': [2],
            },
          ],
        },
    ));
    if(featureAVer == null){
      assert(false, "Failed to register FeatureA feature");
      return false;
    }
    // Register FeatureA running instance
    registry.registerRunningInstance('FeatureA', featureAVer,
      RunningInstance(
        startPoint: 0,
        howManyValues: 8,
        transformationStartIndex: 0,
        transformationEndIndex: 5,
    ));

    // Register FeatureB
    final featureBVer = await registry.registerFeature(
      Feature(
        name: "FeatureB",
        description: "A composite feature combining Duration and FeatureA",
        composites: [
            registry.getFeature("Duration", durationVer)!, 
            registry.getFeature("FeatureA", featureAVer)!,
        ],
        transformationsMap: {
          'FeatureB/Duration': [
            {
              'name': 'Add',
              'args': [5],
            },
            {
              'name': 'Add',
              'args': [3],
            },
          ],
          'FeatureB/FeatureA': [
            {
              'name': 'Add',
              'args': [1],
            },
            {
              'name': 'Add',
              'args': [2],
            },
            {
              'name': 'Add',
              'args': [3],
            },
          ],
        },
    ));
    if(featureBVer == null){
      assert(false, "Failed to register FeatureB feature");
      return false;
    }
    // Register FeatureB running instance
    registry.registerRunningInstance('FeatureB', featureBVer,
      RunningInstance(
        startPoint: 0,
        howManyValues: 8,
        transformationStartIndex: 0,
        transformationEndIndex: 0,
    ));
    return true;
  }
}
