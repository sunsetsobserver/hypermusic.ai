import 'feature.dart';
import 'transformation.dart';

class FeatureCalculator {
  // Generates a sequence space for a given dimension of a feature
  List<int> generateSubfeatureSpace(
      Feature parentFeature, Feature feature, int start, int howMany) {
    print("\nGenerating sequence for ${feature.name}:");
    print("  Start: $start");
    print("  HowMany: $howMany");

    List<int> space = List<int>.filled(howMany, 0);
    int x = start;

    // Get transformations for this feature from the parent
    final transformations =
        parentFeature.transformationsMap[feature.name] ?? [];
    print("  Transformations: $transformations");

    // Generate the sequence
    for (int opId = 0; opId < howMany; opId++) {
      // 1) Put current value into the space array
      space[opId] = x;

      // 2) If there are transformations, pick exactly one based on (opId mod transformations.length)
      if (transformations.isNotEmpty) {
        final index = opId % transformations.length;
        final transformation = transformations[index];
        print(
            "  Step $opId: Applying ${transformation.name}(${transformation.args}) to $x");
        x = _executeTransformation(transformation, x);
      } else {
        // No transformations => default increment
        print("  Step $opId: No transformation, incrementing $x by 1");
        x = x + 1;
      }
    }

    print("  Generated sequence: $space");
    return space;
  }

  // Recursively decomposes a feature into its scalar components
  void decompose(Feature feature, int dest, List<List<int>> outBuffer) {
    print("\nDecomposing feature: ${feature.name}");
    print("Destination index: $dest");
    print("Transformations map: ${feature.transformationsMap}");

    if (dest >= outBuffer.length) {
      throw Exception('Buffer too small');
    }

    if (feature.isScalar) {
      print("${feature.name} is a scalar feature");
      // For scalar features, generate sequence using parent's settings
      final start = feature.startingPoints[feature.name] ?? 0;
      final howMany = feature.howManyValues[feature.name] ?? 1;
      print("Using settings - Start: $start, HowMany: $howMany");

      // Generate sequence directly for scalar features
      final sequence =
          generateSubfeatureSpace(feature, feature, start, howMany);
      outBuffer[dest] = sequence;
      print("Saved sequence to buffer[$dest]: ${outBuffer[dest]}");
      return;
    }

    print(
        "${feature.name} is a composite feature with ${feature.composites.length} components");
    // Process each composite feature
    int currentDest = dest;
    for (final composite in feature.composites) {
      print("\nProcessing composite: ${composite.name}");
      final start = feature.startingPoints[composite.name] ?? 0;
      final howMany = feature.howManyValues[composite.name] ?? 1;
      print("Settings - Start: $start, HowMany: $howMany");

      if (composite.isScalar) {
        print("${composite.name} is scalar, generating sequence");
        // Generate sequence for scalar composite using parent's transformations
        final sequence =
            generateSubfeatureSpace(feature, composite, start, howMany);
        outBuffer[currentDest] = sequence;
        print(
            "Saved sequence to buffer[$currentDest]: ${outBuffer[currentDest]}");
        currentDest++;
      } else {
        print("${composite.name} is composite, processing recursively");
        // Create a new feature instance with the correct settings and transformations
        final subFeature = Feature(
          name: composite.name,
          composites: composite.composites,
          transformationsMap:
              feature.transformationsMap, // Pass parent's transformations
          startingPoints: Map.from(feature.startingPoints),
          howManyValues: Map.from(feature.howManyValues),
        );

        // Recursively process composite
        decompose(subFeature, currentDest, outBuffer);
        currentDest += composite.getScalarsCount();
      }
    }
  }

  // Main entry point for generating samples
  List<List<int>> generateSamples(Feature feature) {
    print("\nGenerating samples for feature: ${feature.name}");
    print("Starting points: ${feature.startingPoints}");
    print("HowMany values: ${feature.howManyValues}");
    print("Transformations: ${feature.transformationsMap}");

    // Get total number of scalar features
    int numberOfScalars = feature.getScalarsCount();
    if (numberOfScalars <= 0) {
      throw Exception('Feature must have at least one scalar');
    }
    print("Total scalar features: $numberOfScalars");

    // Find maximum howMany value to allocate buffers
    int maxHowMany = 1;
    feature.howManyValues.forEach((key, value) {
      if (value != null && value > maxHowMany) {
        maxHowMany = value;
        print("Found larger howMany value: $value for $key");
      }
    });
    print("Using buffer size: $maxHowMany");

    // Allocate buffer for results
    List<List<int>> samplesBuffer =
        List.generate(numberOfScalars, (_) => List<int>.filled(maxHowMany, 0));
    print("Allocated buffer: ${samplesBuffer.length}x$maxHowMany");

    // Decompose the feature
    decompose(feature, 0, samplesBuffer);

    print("\nFinal results:");
    for (int i = 0; i < samplesBuffer.length; i++) {
      print("Scalar $i: ${samplesBuffer[i]}");
    }

    return samplesBuffer;
  }

  // Helper method to execute a single transformation
  int _executeTransformation(Transformation t, int input) {
    final result = switch (t.name) {
      "Add" => input + (t.args[0] as int),
      "Mul" => input * (t.args[0] as int),
      "Nop" => input,
      _ => throw Exception("Unknown transformation: ${t.name}")
    };
    print("    ${t.name}($input) = $result");
    return result;
  }
}
