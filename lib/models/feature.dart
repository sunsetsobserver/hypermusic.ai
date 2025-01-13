class Feature {
  final String name;
  final String description;
  final List<Feature> composites;
  final Map<String, List<Map<String, dynamic>>> transformationsMap;
  final String condition;

  const Feature({
    required this.name,
    required this.description,
    required this.composites,
    required this.transformationsMap,
    this.condition = 'true', // Default condition is always true
  });

  bool get isScalar => composites.isEmpty;

  int getScalarsCount() {
    if (isScalar) return 1;
    return composites.fold(0, (sum, f) => sum + f.getScalarsCount());
  }

  int getSubTreeSize() {
    if (isScalar) return 0;
    return composites.length +
        composites.fold(0, (sum, f) => sum + f.getSubTreeSize());
  }

  Feature copyWith({
    String? name,
    String? description,
    List<Feature>? composites,
    Map<String, List<Map<String, dynamic>>>? transformationsMap,
    String? condition,
  }) {
    // If name is changing, update transformation paths
    if (name != null && name != this.name) {
      final updatedTransformationsMap =
          transformationsMap ?? this.transformationsMap;
      final newTransformationsMap = <String, List<Map<String, dynamic>>>{};

      for (final entry in updatedTransformationsMap.entries) {
        final oldPath = entry.key;
        final newPath = oldPath.replaceFirst(this.name, name);
        newTransformationsMap[newPath] = entry.value;
      }

      return Feature(
        name: name,
        description: description ?? this.description,
        composites: composites ?? this.composites,
        transformationsMap: newTransformationsMap,
        condition: condition ?? this.condition,
      );
    }

    return Feature(
      name: name ?? this.name,
      description: description ?? this.description,
      composites: composites ?? this.composites,
      transformationsMap: transformationsMap ?? this.transformationsMap,
      condition: condition ?? this.condition,
    );
  }

  bool checkCondition() {
    // For now, only support 'true' and 'false' conditions
    return condition == 'true';
  }

  Feature? getComposite(int index) {
    if (index >= composites.length) return null;
    return composites[index];
  }

  int getCompositesCount() => composites.length;

  Map<String, dynamic> transform(int dimId, int opId, int x) {
    if (dimId >= composites.length) throw Exception('Invalid dimension id');

    final subFeature = composites[dimId];
    final transformations = transformationsMap[subFeature.name] ?? [];
    if (transformations.isEmpty) return {'value': x};

    final actualOpId = opId % transformations.length;
    final transformation = transformations[actualOpId];

    final args = transformation['args'] as List<dynamic>;
    if (transformation['name'] == 'Add') {
      return {'value': x + args[0]};
    } else if (transformation['name'] == 'Mul') {
      return {'value': x * args[0]};
    } else if (transformation['name'] == 'Nop') {
      return {'value': x};
    }

    return {'value': x}; // Default no-op
  }
}
