// lib/widgets/models/transformation.dart

class Transformation {
  final String name;
  List<dynamic> args;

  Transformation(this.name, {this.args = const []});

  // Create a copy of the transformation
  Transformation clone() {
    return Transformation(
      name,
      args: List.from(args),
    );
  }
}
