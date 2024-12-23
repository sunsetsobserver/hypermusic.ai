import 'mock_data_store.dart';

class UserToolbox {
  // Maps to store user's private collections
  static final Map<String, Map<String, dynamic>> features = {};
  static final Map<String, Map<String, dynamic>> transformations = {};
  static final Map<String, Map<String, dynamic>> conditions = {};
  static final Map<String, Map<String, dynamic>> performativeTransactions = {};

  // Initialize toolbox with all items from MockDataStore
  static void initializeFromMockData() {
    // Copy features
    MockDataStore.features.forEach((key, value) {
      features[key] = Map.from(value);
    });

    // Copy transformations
    MockDataStore.transformations.forEach((key, value) {
      transformations[key] = Map.from(value);
    });

    // Copy conditions
    MockDataStore.conditions.forEach((key, value) {
      conditions[key] = Map.from(value);
    });

    // Copy performative transactions
    MockDataStore.performativeTransactions.forEach((key, value) {
      performativeTransactions[key] = Map.from(value);
    });
  }

  // Methods to manage features
  static void addFeature(String name, Map<String, dynamic> featureData) {
    features[name] = featureData;
  }

  static void removeFeature(String name) {
    features.remove(name);
  }

  static bool hasFeature(String name) {
    return features.containsKey(name);
  }

  // Methods to manage transformations
  static void addTransformation(
      String name, Map<String, dynamic> transformationData) {
    transformations[name] = transformationData;
  }

  static void removeTransformation(String name) {
    transformations.remove(name);
  }

  static bool hasTransformation(String name) {
    return transformations.containsKey(name);
  }

  // Methods to manage conditions
  static void addCondition(String name, Map<String, dynamic> conditionData) {
    conditions[name] = conditionData;
  }

  static void removeCondition(String name) {
    conditions.remove(name);
  }

  static bool hasCondition(String name) {
    return conditions.containsKey(name);
  }

  // Methods to manage performative transactions
  static void addPerformativeTransaction(
      String name, Map<String, dynamic> ptData) {
    performativeTransactions[name] = ptData;
  }

  static void removePerformativeTransaction(String name) {
    performativeTransactions.remove(name);
  }

  static bool hasPerformativeTransaction(String name) {
    return performativeTransactions.containsKey(name);
  }
}
