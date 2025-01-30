class RunningInstance {
  final int startPoint;
  final int howManyValues;
  final int transformationStartIndex;
  final int transformationEndIndex;

  const RunningInstance({
    required this.startPoint,
    required this.howManyValues,
    required this.transformationStartIndex,
    required this.transformationEndIndex,
  });

  Map<String, dynamic> toJson(RunningInstance instance) {
    return {
      'startPoint': instance.startPoint,
      'howManyValues': instance.howManyValues,
      'transformationStartIndex': instance.transformationStartIndex,
      'transformationEndIndex': instance.transformationEndIndex,
    };
  }

  RunningInstance copyWith({int? startPoint, int? howManyValues, int? transformationStartIndex, int? transformationEndIndex}) {
    return RunningInstance(
      startPoint: startPoint ?? this.startPoint,
      howManyValues: howManyValues ?? this.howManyValues,
      transformationStartIndex: transformationStartIndex ?? this.transformationStartIndex,
      transformationEndIndex: transformationEndIndex ?? this.transformationEndIndex,
    );
  }
}
