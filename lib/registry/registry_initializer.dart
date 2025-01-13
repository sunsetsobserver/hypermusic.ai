import '../models/feature.dart';
import 'registry.dart';

class RegistryInitializer {
  static void initialize(Registry registry) {
    if (registry.isInitialized) {
      return;
    }

    // Register scalar features first
    final pitch = Feature(
      name: "Pitch",
      description: "A scalar feature representing pitch",
      composites: [],
      transformationsMap: {},
    );
    registry.addFeature(pitch);

    final time = Feature(
      name: "Time",
      description: "A scalar feature representing time",
      composites: [],
      transformationsMap: {},
    );
    registry.addFeature(time);

    final duration = Feature(
      name: "Duration",
      description: "A scalar feature representing duration",
      composites: [],
      transformationsMap: {},
    );
    registry.addFeature(duration);

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
    );
    registry.addFeature(featureA);

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
    );
    registry.addFeature(featureB);

    registry.ensureInitialized();
  }
}
