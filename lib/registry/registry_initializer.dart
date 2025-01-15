import '../models/feature.dart';
import '../models/running_instance.dart';
import 'registry.dart';

class RegistryInitializer {
  static Feature getRootFeatureTemplate() {
    return Feature(
      name: "Root",
      description: "Root feature for composition",
      composites: [],
      transformationsMap: {},
      startPoint: 0,
      howManyValues: 16,
    );
  }

  static void initialize(Registry registry) {
    if (registry.isInitialized) {
      return;
    }

    final initTimestamp = DateTime.now().millisecondsSinceEpoch;

    // Register scalar features first
    final pitch = Feature(
      name: "Pitch",
      description: "A scalar feature representing pitch",
      composites: [],
      transformationsMap: {},
      startPoint: 60,
      howManyValues: 12,
    );
    registry.addFeature(pitch);
    registry.addRunningInstance(RunningInstance(
      id: 'Pitch_${initTimestamp}_(registered)',
      feature: pitch.copyWith(name: 'Pitch_${initTimestamp}_(registered)'),
      startPoint: pitch.startPoint,
      howManyValues: pitch.howManyValues,
      transformationStartIndex: 0,
      transformationEndIndex: pitch.howManyValues - 1,
    ));

    final time = Feature(
      name: "Time",
      description: "A scalar feature representing time",
      composites: [],
      transformationsMap: {},
      startPoint: 0,
      howManyValues: 16,
    );
    registry.addFeature(time);
    registry.addRunningInstance(RunningInstance(
      id: 'Time_${initTimestamp}_(registered)',
      feature: time.copyWith(name: 'Time_${initTimestamp}_(registered)'),
      startPoint: time.startPoint,
      howManyValues: time.howManyValues,
      transformationStartIndex: 0,
      transformationEndIndex: time.howManyValues - 1,
    ));

    final duration = Feature(
      name: "Duration",
      description: "A scalar feature representing duration",
      composites: [],
      transformationsMap: {},
      startPoint: 1,
      howManyValues: 8,
    );
    registry.addFeature(duration);
    registry.addRunningInstance(RunningInstance(
      id: 'Duration_${initTimestamp}_(registered)',
      feature:
          duration.copyWith(name: 'Duration_${initTimestamp}_(registered)'),
      startPoint: duration.startPoint,
      howManyValues: duration.howManyValues,
      transformationStartIndex: 0,
      transformationEndIndex: duration.howManyValues - 1,
    ));

    // Register composite features
    final featureA = Feature(
      name: "FeatureA",
      description: "A composite feature combining Pitch and Time",
      composites: [pitch, time],
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
      startPoint: 0,
      howManyValues: 16,
    );
    registry.addFeature(featureA);
    registry.addRunningInstance(RunningInstance(
      id: 'FeatureA_${initTimestamp}_(registered)',
      feature:
          featureA.copyWith(name: 'FeatureA_${initTimestamp}_(registered)'),
      startPoint: featureA.startPoint,
      howManyValues: featureA.howManyValues,
      transformationStartIndex: 0,
      transformationEndIndex: featureA.howManyValues - 1,
    ));

    final featureB = Feature(
      name: "FeatureB",
      description: "A composite feature combining Duration and FeatureA",
      composites: [duration, featureA],
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
      startPoint: 0,
      howManyValues: 32,
    );
    registry.addFeature(featureB);
    registry.addRunningInstance(RunningInstance(
      id: 'FeatureB_${initTimestamp}_(registered)',
      feature:
          featureB.copyWith(name: 'FeatureB_${initTimestamp}_(registered)'),
      startPoint: featureB.startPoint,
      howManyValues: featureB.howManyValues,
      transformationStartIndex: 0,
      transformationEndIndex: featureB.howManyValues - 1,
    ));

    registry.ensureInitialized();
  }
}
