import 'dart:math' show min;
import 'feature.dart';
import 'transformation.dart';

class FeatureRunner {
  // Executes a transformation on an input index
  int _executeTransformation(Transformation t, int input) {
    final result = switch (t.name) {
      "Add" => input + (t.args[0] as int),
      "Mul" => input * (t.args[0] as int),
      "Nop" => input,
      _ => throw Exception("Unknown transformation: ${t.name}")
    };
    print("Executing ${t.name}(${t.args[0]}) on $input = $result");
    return result;
  }

  // Main entry point to run a feature
  List<List<int>> runFeature(Feature feature, int defaultHowMany) {
    print("\nRunning feature: ${feature.name}");
    print("Starting points: ${feature.startingPoints}");
    print("HowMany values: ${feature.howManyValues}");
    print("Transformations: ${feature.transformationsMap}");

    // For scalar features, just return a sequence
    if (feature.isScalar) {
      final startIndex = feature.startingPoints[feature.name] ?? 0;
      final howMany = feature.howManyValues[feature.name] ?? defaultHowMany;
      print(
          "Scalar feature ${feature.name}: startIndex=$startIndex, howMany=$howMany");
      return [_generateSequence(startIndex, howMany)];
    }

    // Initialize results buffer for each scalar in the feature tree
    List<List<int>> results = [];
    for (int i = 0; i < feature.getScalarsCount(); i++) {
      results.add([]);
    }

    // Process each composite feature
    int resultIndex = 0;
    for (final composite in feature.composites) {
      print("\nProcessing composite: ${composite.name}");
      // Get this composite's howMany value, or use parent's if not set
      final howMany = feature.howManyValues[composite.name] ?? defaultHowMany;
      final startIndex = feature.startingPoints[composite.name] ?? 0;
      print("Using startIndex=$startIndex, howMany=$howMany");

      if (composite.isScalar) {
        // Get transformations for this composite
        final transformations =
            feature.getTransformationsForSubFeature(composite.name);
        print("Transformations for ${composite.name}: $transformations");

        // Initialize the result sequence
        List<int> sequence = [];

        if (transformations.isEmpty) {
          print(
              "No transformations, generating sequence from $startIndex to ${startIndex + howMany - 1}");
          sequence = _generateSequence(startIndex, howMany);
        } else {
          // Apply transformations
          int currentValue = startIndex;
          sequence.add(currentValue); // First value is the starting point
          print("First value (starting point): $currentValue");

          // Generate remaining values by applying transformations
          for (int i = 1; i < howMany; i++) {
            final transformation =
                transformations[(i - 1) % transformations.length];
            print(
                "Step $i: Applying ${transformation.name}(${transformation.args[0]}) to $currentValue");
            currentValue = _executeTransformation(transformation, currentValue);
            sequence.add(currentValue);
          }
        }

        print("Final sequence for ${composite.name}: $sequence");
        results[resultIndex] = sequence;
        resultIndex++;
      } else {
        // For compound composites, recursively process with parent's values
        composite.startingPoints = feature.startingPoints;
        composite.howManyValues = feature.howManyValues;
        composite.transformationsMap = feature.transformationsMap;
        final subResults = runFeature(composite, howMany);
        for (var subResult in subResults) {
          results[resultIndex] = subResult;
          resultIndex++;
        }
      }
    }

    return results;
  }

  // Generates a sequence of indices from a starting point
  List<int> _generateSequence(int start, int howMany) {
    List<int> sequence = [];
    for (int i = 0; i < howMany; i++) {
      sequence.add(start + i);
    }
    return sequence;
  }

  // Helper method to print results in a readable format
  void printResults(List<List<int>> results) {
    print("\nFeature execution results:");
    for (int i = 0; i < results.length; i++) {
      print("Scalar $i: ${results[i]}");
    }
  }
}
