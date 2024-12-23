// lib/mock/mock_api.dart

import '../interfaces/data_interface.dart';
import 'mock_data_store.dart';

class MockAPI implements DataInterface {
  @override
  Future<Map<String, dynamic>> getFeature(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataStore.features[name] ?? {};
  }

  @override
  Future<List<String>> getAllFeatures() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataStore.features.keys.toList();
  }

  @override
  Future<Map<String, dynamic>> getTransformation(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataStore.transformations[name] ?? {};
  }

  @override
  Future<List<String>> getAllTransformations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataStore.transformations.keys.toList();
  }

  @override
  Future<void> registerFeature(
    String name,
    List<String> composites,
    List<Map<String, dynamic>> transformations, {
    Map<String, dynamic>? startingPoints,
    Map<String, dynamic>? howManyValues,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Use provided starting points or initialize new ones
    final Map<String, dynamic> finalStartingPoints = startingPoints ?? {};
    final Map<String, dynamic> finalHowManyValues = howManyValues ?? {};

    // Ensure all composites have entries
    for (var composite in composites) {
      if (!finalStartingPoints.containsKey(composite)) {
        finalStartingPoints[composite] = null;
      }
      if (!finalHowManyValues.containsKey(composite)) {
        finalHowManyValues[composite] = null;
      }
    }

    MockDataStore.features[name] = {
      "name": name,
      "composites": composites,
      "transformations": transformations,
      "startingPoints": finalStartingPoints,
      "howManyValues": finalHowManyValues,
    };
  }

  @override
  Future<void> registerTransformation(
      String name, int argsCount, String description) async {
    await Future.delayed(const Duration(milliseconds: 100));
    MockDataStore.transformations[name] = {
      "name": name,
      "argsCount": argsCount,
      "description": description,
    };
  }

  @override
  Future<Map<String, dynamic>> getCondition(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataStore.conditions[name] ?? {};
  }

  @override
  Future<List<String>> getAllConditions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataStore.conditions.keys.toList();
  }

  @override
  Future<Map<String, dynamic>> getPerformativeTransaction(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataStore.performativeTransactions[name] ?? {};
  }

  @override
  Future<List<String>> getAllPerformativeTransactions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataStore.performativeTransactions.keys.toList();
  }
}
