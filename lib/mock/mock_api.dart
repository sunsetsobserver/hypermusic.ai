// lib/mock/mock_api.dart

import '../interfaces/data_interface.dart';
import 'mock_data_store.dart';

class MockAPI implements DataInterface {
  @override
  Future<Map<String, dynamic>> getFeature(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Returns the raw map for now.
    // The UI or logic layer can convert this map into a Feature object.
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
  Future<void> registerFeature(String name, List<String> composites,
      List<Map<String, dynamic>> transformations) async {
    // transformations are expected dimension-based now:
    // i.e. transformations = [
    //   [ {name:"Add",args:[1]}, {name:"Mul",args:[2]} ],
    //   [ {name:"Nop",args:[]}, ...]
    // ]
    await Future.delayed(const Duration(milliseconds: 100));
    MockDataStore.features[name] = {
      "name": name,
      "composites": composites,
      "transformations": transformations,
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
