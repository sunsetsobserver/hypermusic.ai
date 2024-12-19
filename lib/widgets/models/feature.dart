// lib/widgets/models/feature.dart
import 'transformation.dart';
import 'condition.dart';

class Feature {
  final String name;
  List<Feature> composites;
  List<List<Transformation>> transformations;

  Feature({
    required this.name,
    this.composites = const [],
    this.transformations = const [],
  });

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
    composites = List.from(composites)..add(f);
    transformations = List.from(transformations)..add([]);
  }
}
