
class Feature 
{
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
    this.condition = 'true',
  });

  Map<String, dynamic> toJson(Feature feature) {
    return {
      'name': feature.name,
      'description': feature.description,
      'composites': feature.composites,
      'transformationsMap': feature.transformationsMap,
      'condition': feature.condition,
    };
  }

  Feature copyWith({String? name, String? description, List<Feature>? composites, Map<String, List<Map<String, dynamic>>>? transformationsMap, String? condition}) {
    return Feature(
      name: name ?? this.name,
      description: description ?? this.description,
      composites: composites ?? this.composites,
      transformationsMap: transformationsMap ?? this.transformationsMap,
      condition: condition ?? this.condition,
    );
  }

  bool isScalar() => composites.isEmpty;
  
  int getScalarsCount() => composites.fold(0, (sum, composite) => sum + composite.getScalarsCount());
  
  int getSubTreeSize() {
    if (isScalar()) return 0;
    return composites.length + composites.fold(0, (sum, composite) => sum + composite.getSubTreeSize());
  }

  bool checkCondition() {
    // For now, only support 'true' and 'false' conditions
    return condition == 'true';
  }

  Map<String, dynamic> transform(int dimId, int opId, int x) {

    if (dimId >= composites.length) throw Exception('Invalid dimension id');

    final subFeature = composites[dimId];
    final transformations = transformationsMap[subFeature] ?? [];
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
