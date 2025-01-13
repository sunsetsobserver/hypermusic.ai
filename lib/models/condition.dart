class Condition {
  final String name;
  final String description;

  Condition({
    required this.name,
    required this.description,
  });

  bool evaluate(int input) {
    return switch (name) {
      'ConditionA' => input > 5,
      'ConditionB' => input % 2 == 0,
      _ => throw Exception('Unknown condition: $name')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
