import 'feature.dart';

class RunningInstance {
  final String id;
  final Feature feature;
  final int startPoint;
  final int howManyValues;
  final int transformationStartIndex;
  final int transformationEndIndex;

  const RunningInstance({
    required this.id,
    required this.feature,
    required this.startPoint,
    required this.howManyValues,
    required this.transformationStartIndex,
    required this.transformationEndIndex,
  });

  RunningInstance copyWith({
    String? id,
    Feature? feature,
    int? startPoint,
    int? howManyValues,
    int? transformationStartIndex,
    int? transformationEndIndex,
  }) {
    return RunningInstance(
      id: id ?? this.id,
      feature: feature ?? this.feature,
      startPoint: startPoint ?? this.startPoint,
      howManyValues: howManyValues ?? this.howManyValues,
      transformationStartIndex:
          transformationStartIndex ?? this.transformationStartIndex,
      transformationEndIndex:
          transformationEndIndex ?? this.transformationEndIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feature': feature.name,
      'startPoint': startPoint,
      'howManyValues': howManyValues,
      'transformationStartIndex': transformationStartIndex,
      'transformationEndIndex': transformationEndIndex,
    };
  }
}
