class Transformation {
  final String name;
  final List<int> args;

  Transformation(this.name, {this.args = const []});

  int run(int x) {
    return switch (name) {
      'Add' => x + (args.isNotEmpty ? args[0] : 0),
      'Mul' => x * (args.isNotEmpty ? args[0] : 1),
      'Nop' => x,
      _ => throw Exception('Unknown transformation: $name')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'argsCount': args.length,
      'description': _getDescription(),
    };
  }

  String _getDescription() {
    return switch (name) {
      'Add' => 'Adds a constant to the input index',
      'Mul' => 'Multiplies the input index by a constant',
      'Nop' => 'No operation',
      _ => 'Unknown transformation'
    };
  }
}
