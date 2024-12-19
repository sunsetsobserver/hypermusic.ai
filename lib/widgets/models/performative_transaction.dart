// lib/widgets/models/performative_transaction.dart

import 'feature.dart';
import 'condition.dart';

class PerformativeTransaction {
  final String name;
  final String description;
  final Feature feature;
  final Condition condition;

  const PerformativeTransaction({
    required this.name,
    required this.description,
    required this.feature,
    required this.condition,
  });
}
