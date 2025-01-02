// lib/widgets/models/feature.dart
import 'transformation.dart';

class Feature {
  final String name;
  List<Feature> composites;
  Map<String, List<Transformation>> transformationsMap;
  Map<String, int?> startingPoints;
  Map<String, int?> howManyValues;
  final bool isTemplate;

  Feature({
    required this.name,
    this.composites = const [],
    Map<String, List<Transformation>>? transformationsMap,
    Map<String, int?>? startingPoints,
    Map<String, int?>? howManyValues,
    this.isTemplate = false,
  })  : transformationsMap = transformationsMap ?? {},
        startingPoints = startingPoints ?? {},
        howManyValues = howManyValues ?? {};

  // Create a deep copy of the feature
  Feature clone() {
    // If this is a template feature, create a new instance without transformations
    if (isTemplate) {
      return Feature(
        name: name,
        composites: [],
        transformationsMap: {}, // Empty transformations for template features
        isTemplate: isTemplate,
      );
    }

    // Create a deep copy of transformations
    final newTransformationsMap = <String, List<Transformation>>{};
    transformationsMap.forEach((key, value) {
      newTransformationsMap[key] = value.map((t) => t.clone()).toList();
    });

    // Create a deep copy of composites
    final newComposites = composites.map((f) => f.clone()).toList();

    return Feature(
      name: name,
      composites: newComposites,
      transformationsMap: newTransformationsMap,
      startingPoints: Map.from(startingPoints),
      howManyValues: Map.from(howManyValues),
      isTemplate: isTemplate,
    );
  }

  // Create a copy with a new name
  Feature copyWithNewName(String newName) {
    return Feature(
      name: newName,
      composites: composites.map((f) => f.clone()).toList(),
      transformationsMap: Map.from(transformationsMap),
      startingPoints: Map.from(startingPoints),
      howManyValues: Map.from(howManyValues),
    );
  }

  // Get whether this feature is scalar (has no composites)
  bool get isScalar => composites.isEmpty;

  // Get the total number of scalar features in this feature's hierarchy
  int getScalarsCount() {
    if (isScalar) return 1;
    return composites.fold<int>(
        0, (sum, composite) => sum + composite.getScalarsCount());
  }

  // Get transformations for a specific sub-feature
  List<Transformation> getTransformationsForSubFeature(String subFeatureName) {
    return transformationsMap[subFeatureName] ?? [];
  }

  void addComposite(Feature f) {
    // Clone the feature before adding it to ensure it's a separate instance
    final clonedFeature = f.clone();
    composites = List.from(composites)..add(clonedFeature);
    if (!isScalar) {
      // Only initialize if not already present
      if (!transformationsMap.containsKey(clonedFeature.name)) {
        transformationsMap[clonedFeature.name] = [];
        startingPoints[clonedFeature.name] = null;
        howManyValues[clonedFeature.name] = null;
      }
    }
  }

  // Add a transformation for a specific sub-feature
  void addTransformationForSubFeature(
      String subFeatureName, Transformation transformation) {
    if (!transformationsMap.containsKey(subFeatureName)) {
      transformationsMap[subFeatureName] = [];
    }
    // Always add the transformation, allowing multiple of same type
    transformationsMap[subFeatureName]!.add(transformation.clone());
  }

  // Update a transformation for a specific sub-feature
  void updateTransformationForSubFeature(
      String subFeatureName, Transformation transformation) {
    if (!transformationsMap.containsKey(subFeatureName)) {
      transformationsMap[subFeatureName] = [];
    }
    // Find and update the existing transformation by index
    final existingIndex = transformationsMap[subFeatureName]!
        .indexWhere((t) => t == transformation);
    if (existingIndex != -1) {
      transformationsMap[subFeatureName]![existingIndex] =
          transformation.clone();
    } else {
      // If it doesn't exist, add it
      transformationsMap[subFeatureName]!.add(transformation.clone());
    }
  }

  // Remove a transformation for a specific sub-feature
  void removeTransformationForSubFeature(String subFeatureName, int index) {
    if (transformationsMap.containsKey(subFeatureName) &&
        index < transformationsMap[subFeatureName]!.length) {
      transformationsMap[subFeatureName]!.removeAt(index);
    }
  }

  // Set starting point for a specific sub-feature
  void setStartingPoint(String subFeatureName, int? value) {
    startingPoints[subFeatureName] = value;
  }

  // Set howMany for a specific sub-feature
  void setHowMany(String subFeatureName, int? value) {
    howManyValues[subFeatureName] = value;
  }
}
