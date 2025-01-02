import 'feature.dart';
import 'feature_calculator.dart';

class FeatureRunner {
  final FeatureCalculator _calculator = FeatureCalculator();

  // Main entry point to run a feature
  List<List<int>> runFeature(Feature feature, int defaultHowMany) {
    print("\nRunning feature: ${feature.name}");
    print("Starting points: ${feature.startingPoints}");
    print("HowMany values: ${feature.howManyValues}");
    print("Transformations: ${feature.transformationsMap}");

    // Set default howMany value if not set
    if (feature.howManyValues.isEmpty) {
      feature.howManyValues[feature.name] = defaultHowMany;
    }

    // Use the calculator to generate samples
    final results = _calculator.generateSamples(feature);
    printResults(results);
    return results;
  }

  // Helper method to print results in a readable format
  void printResults(List<List<int>> results) {
    print("\nFeature execution results:");
    for (int i = 0; i < results.length; i++) {
      print("Scalar $i: ${results[i]}");
    }
  }
}
