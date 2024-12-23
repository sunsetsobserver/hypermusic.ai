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
    composites = List.from(composites)..add(f.clone()); // Clone when adding
    if (!isScalar) {
      // Initialize transformations, startingPoint and howMany for the new composite
      transformationsMap[f.name] = [];
      startingPoints[f.name] = null;
      howManyValues[f.name] = null;
    }
  }

  void addTransformation(String subFeatureName, Transformation t) {
    if (!transformationsMap.containsKey(subFeatureName)) {
      transformationsMap[subFeatureName] = [];
    }
    transformationsMap[subFeatureName]!.add(t.clone());
  }

  void removeTransformation(String subFeatureName, int index) {
    if (transformationsMap.containsKey(subFeatureName) &&
        transformationsMap[subFeatureName]!.length > index) {
      transformationsMap[subFeatureName]!.removeAt(index);
    }
  }

  List<Transformation> getTransformationsForSubFeature(String subFeatureName) {
    return transformationsMap[subFeatureName] ?? [];
  }

  void setStartingPoint(String featureName, int? value) {
    startingPoints[featureName] = value;
  }

  void setHowMany(String featureName, int? value) {
    howManyValues[featureName] = value;
  }
}
