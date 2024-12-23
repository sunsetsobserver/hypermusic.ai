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

    // Otherwise, clone everything
    return Feature(
      name: name,
      composites: composites.map((f) => f.clone()).toList(),
      transformationsMap: transformationsMap.map(
        (key, value) => MapEntry(key, value.map((t) => t.clone()).toList()),
      ),
      startingPoints: Map.from(startingPoints),
      howManyValues: Map.from(howManyValues),
      isTemplate: isTemplate,
    );
  }

  // Create a copy of the feature with a new name
  Feature copyWithNewName(String newName) {
    return Feature(
      name: newName,
      composites: composites.map((f) => f.clone()).toList(),
      transformationsMap: transformationsMap.map(
        (key, value) => MapEntry(key, value.map((t) => t.clone()).toList()),
      ),
      startingPoints: Map.from(startingPoints),
      howManyValues: Map.from(howManyValues),
      isTemplate: false, // The copy is never a template
    );
  }

  bool get isScalar => composites.isEmpty;

  int getScalarsCount() {
    if (isScalar) return 1;
    int count = 0;
    for (final c in composites) {
      count += c.getScalarsCount();
    }
    return count;
  }

  int getSubTreeSize() {
    if (isScalar) return 0;
    int size = composites.length;
    for (final c in composites) {
      size += c.getSubTreeSize();
    }
    return size;
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

  // Get transformations for a specific sub-feature
  List<Transformation> getTransformationsForSubFeature(String subFeatureName) {
    return transformationsMap[subFeatureName] ?? [];
  }

  // Add a transformation for a specific sub-feature
  void addTransformationForSubFeature(
      String subFeatureName, Transformation transformation) {
    if (!transformationsMap.containsKey(subFeatureName)) {
      transformationsMap[subFeatureName] = [];
    }
    transformationsMap[subFeatureName]!.add(transformation);
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
