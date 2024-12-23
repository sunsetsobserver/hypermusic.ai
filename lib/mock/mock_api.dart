// lib/mock/mock_api.dart

import '../interfaces/data_interface.dart';
import 'mock_data_store.dart';
import 'user_toolbox.dart';

class MockAPI implements DataInterface {
  MockAPI() {
    // Initialize user's toolbox with mock data
    UserToolbox.initializeFromMockData();
  }

  @override
  Future<Map<String, dynamic>> getFeature(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return UserToolbox.features[name] ?? {};
  }

  @override
  Future<List<String>> getAllFeatures() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return UserToolbox.features.keys.toList();
  }

  @override
  Future<Map<String, dynamic>> getTransformation(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return UserToolbox.transformations[name] ?? {};
  }

  @override
  Future<List<String>> getAllTransformations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return UserToolbox.transformations.keys.toList();
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

    // Register in both MockDataStore and UserToolbox
    final featureData = {
      "name": name,
      "composites": composites,
      "transformations": transformations,
      "startingPoints": finalStartingPoints,
      "howManyValues": finalHowManyValues,
    };

    MockDataStore.features[name] = featureData;
    UserToolbox.addFeature(name, featureData);
  }

  @override
  Future<void> registerTransformation(
      String name, int argsCount, String description) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final transformationData = {
      "name": name,
      "argsCount": argsCount,
      "description": description,
    };

    MockDataStore.transformations[name] = transformationData;
    UserToolbox.addTransformation(name, transformationData);
  }

  @override
  Future<Map<String, dynamic>> getCondition(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return UserToolbox.conditions[name] ?? {};
  }

  @override
  Future<List<String>> getAllConditions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return UserToolbox.conditions.keys.toList();
  }

  @override
  Future<Map<String, dynamic>> getPerformativeTransaction(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return UserToolbox.performativeTransactions[name] ?? {};
  }

  @override
  Future<List<String>> getAllPerformativeTransactions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return UserToolbox.performativeTransactions.keys.toList();
  }
}
