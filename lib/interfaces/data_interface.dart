// lib/interfaces/data_interface.dart

abstract class DataInterface {
  Future<Map<String, dynamic>> getFeature(String name);
  Future<List<String>> getAllFeatures();
  Future<Map<String, dynamic>> getTransformation(String name);
  Future<void> registerFeature(String name, List<String> composites,
      List<Map<String, dynamic>> transformations);
  Future<void> registerTransformation(
      String name, int argsCount, String description);

  Future<Map<String, dynamic>> getCondition(String name);
  Future<List<String>> getAllConditions();

  Future<Map<String, dynamic>> getPerformativeTransaction(String name);
  Future<List<String>> getAllPerformativeTransactions();

  Future<List<String>> getAllTransformations();
}
