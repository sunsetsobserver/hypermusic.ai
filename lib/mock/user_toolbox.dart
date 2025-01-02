import 'mock_data_store.dart';

class UserToolbox {
  // Maps to store references to user's selected items
  static final Set<String> featureNames = {};
  static final Set<String> transformationNames = {};
  static final Set<String> conditionNames = {};
  static final Set<String> performativeTransactionNames = {};

  // Initialize toolbox with all items from MockDataStore
  static void initializeFromMockData() {
    // Add references to features
    for (final key in MockDataStore.features.keys) {
      featureNames.add(key);
    }

    // Add references to transformations
    for (final key in MockDataStore.transformations.keys) {
      transformationNames.add(key);
    }

    // Add references to conditions
    for (final key in MockDataStore.conditions.keys) {
      conditionNames.add(key);
    }

    // Add references to performative transactions
    for (final key in MockDataStore.performativeTransactions.keys) {
      performativeTransactionNames.add(key);
    }
  }

  // Methods to manage features
  static void addFeature(String name, Map<String, dynamic> featureData) {
    // Add to MockDataStore first
    MockDataStore.features[name] = featureData;
    // Then add reference to toolbox
    featureNames.add(name);
  }

  static void removeFeature(String name) {
    featureNames.remove(name);
  }

  static bool hasFeature(String name) {
    return featureNames.contains(name);
  }

  // Get feature data from MockDataStore
  static Map<String, dynamic>? getFeature(String name) {
    if (!hasFeature(name)) return null;
    return MockDataStore.features[name];
  }

  // Get all features from MockDataStore that are in the toolbox
  static Map<String, Map<String, dynamic>> get features {
    final result = <String, Map<String, dynamic>>{};
    for (final name in featureNames) {
      final feature = MockDataStore.features[name];
      if (feature != null) {
        result[name] = feature;
      }
    }
    return result;
  }

  // Methods to manage transformations
  static void addTransformation(
      String name, Map<String, dynamic> transformationData) {
    // Add to MockDataStore first
    MockDataStore.transformations[name] = transformationData;
    // Then add reference to toolbox
    transformationNames.add(name);
  }

  static void removeTransformation(String name) {
    transformationNames.remove(name);
  }

  static bool hasTransformation(String name) {
    return transformationNames.contains(name);
  }

  // Get transformation data from MockDataStore
  static Map<String, dynamic>? getTransformation(String name) {
    if (!hasTransformation(name)) return null;
    return MockDataStore.transformations[name];
  }

  // Get all transformations from MockDataStore that are in the toolbox
  static Map<String, Map<String, dynamic>> get transformations {
    final result = <String, Map<String, dynamic>>{};
    for (final name in transformationNames) {
      final transformation = MockDataStore.transformations[name];
      if (transformation != null) {
        result[name] = transformation;
      }
    }
    return result;
  }

  // Methods to manage conditions
  static void addCondition(String name, Map<String, dynamic> conditionData) {
    // Add to MockDataStore first
    MockDataStore.conditions[name] = conditionData;
    // Then add reference to toolbox
    conditionNames.add(name);
  }

  static void removeCondition(String name) {
    conditionNames.remove(name);
  }

  static bool hasCondition(String name) {
    return conditionNames.contains(name);
  }

  // Get condition data from MockDataStore
  static Map<String, dynamic>? getCondition(String name) {
    if (!hasCondition(name)) return null;
    return MockDataStore.conditions[name];
  }

  // Get all conditions from MockDataStore that are in the toolbox
  static Map<String, Map<String, dynamic>> get conditions {
    final result = <String, Map<String, dynamic>>{};
    for (final name in conditionNames) {
      final condition = MockDataStore.conditions[name];
      if (condition != null) {
        result[name] = condition;
      }
    }
    return result;
  }

  // Methods to manage performative transactions
  static void addPerformativeTransaction(
      String name, Map<String, dynamic> ptData) {
    // Add to MockDataStore first
    MockDataStore.performativeTransactions[name] = ptData;
    // Then add reference to toolbox
    performativeTransactionNames.add(name);
  }

  static void removePerformativeTransaction(String name) {
    performativeTransactionNames.remove(name);
  }

  static bool hasPerformativeTransaction(String name) {
    return performativeTransactionNames.contains(name);
  }

  // Get performative transaction data from MockDataStore
  static Map<String, dynamic>? getPerformativeTransaction(String name) {
    if (!hasPerformativeTransaction(name)) return null;
    return MockDataStore.performativeTransactions[name];
  }

  // Get all performative transactions from MockDataStore that are in the toolbox
  static Map<String, Map<String, dynamic>> get performativeTransactions {
    final result = <String, Map<String, dynamic>>{};
    for (final name in performativeTransactionNames) {
      final pt = MockDataStore.performativeTransactions[name];
      if (pt != null) {
        result[name] = pt;
      }
    }
    return result;
  }
}
