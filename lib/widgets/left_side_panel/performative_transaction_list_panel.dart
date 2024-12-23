// lib/widgets/left_side_panel/performative_transaction_list_panel.dart

import 'package:flutter/material.dart';
import '../models/performative_transaction.dart';
import '../models/feature.dart';
import '../models/condition.dart';
import '../models/transformation.dart';
import 'panel_header.dart';
import 'category_section.dart';
import 'draggable_pt_item.dart';
import '../../interfaces/data_interface.dart';

class PerformativeTransactionListPanel extends StatefulWidget {
  final DataInterface dataInterface;

  const PerformativeTransactionListPanel(
      {super.key, required this.dataInterface});

  @override
  State<PerformativeTransactionListPanel> createState() =>
      _PerformativeTransactionListPanelState();
}

class _PerformativeTransactionListPanelState
    extends State<PerformativeTransactionListPanel> {
  late Future<List<PerformativeTransaction>> _ptFuture;

  @override
  void initState() {
    super.initState();
    _ptFuture = _loadPerformativeTransactions();
  }

  Future<Feature> _parseFeature(Map<dynamic, dynamic> data) async {
    List<Feature> compositeFeatures = [];
    for (final cName in (data["composites"] as List)) {
      final cData = await widget.dataInterface.getFeature(cName as String);
      final cFeature = await _parseFeature(cData);
      compositeFeatures.add(cFeature);
    }

    // Parse transformations
    Map<String, List<Transformation>> transformationsMap = {};
    final transformationsList = data["transformations"] as List;
    for (final tData in transformationsList) {
      final Map<dynamic, dynamic> transMap = tData as Map<dynamic, dynamic>;
      final subFeatureName = transMap["subFeatureName"] as String;
      if (!transformationsMap.containsKey(subFeatureName)) {
        transformationsMap[subFeatureName] = [];
      }
      transformationsMap[subFeatureName]!.add(
        Transformation(
          transMap["name"] as String,
          args: (transMap["args"] as List?)?.cast<dynamic>() ?? [],
        ),
      );
    }

    // Parse starting points
    Map<String, int?> startingPoints = {};
    if (data["startingPoints"] != null) {
      final startingPointsMap = data["startingPoints"] as Map<dynamic, dynamic>;
      startingPoints = startingPointsMap
          .map((key, value) => MapEntry(key.toString(), value as int?));
    }

    // Parse howMany values
    Map<String, int?> howManyValues = {};
    if (data["howManyValues"] != null) {
      final howManyMap = data["howManyValues"] as Map<dynamic, dynamic>;
      howManyValues = howManyMap
          .map((key, value) => MapEntry(key.toString(), value as int?));
    }

    return Feature(
      name: data["name"] as String,
      composites: compositeFeatures,
      transformationsMap: transformationsMap,
      startingPoints: startingPoints,
      howManyValues: howManyValues,
      isTemplate: data["isTemplate"] as bool? ?? false,
    );
  }

  Future<List<PerformativeTransaction>> _loadPerformativeTransactions() async {
    final ptNames = await widget.dataInterface.getAllPerformativeTransactions();
    List<PerformativeTransaction> pts = [];

    for (final ptName in ptNames) {
      final ptData =
          await widget.dataInterface.getPerformativeTransaction(ptName);

      // Parse condition
      final conditionData = await widget.dataInterface
          .getCondition(ptData["condition"] as String);
      final condition = Condition(
        conditionData["name"] as String,
        description: conditionData["description"] as String,
      );

      // Parse feature
      final featureData =
          await widget.dataInterface.getFeature(ptData["feature"] as String);
      final feature = await _parseFeature(featureData);

      final pt = PerformativeTransaction(
        name: ptData["name"] as String,
        description: ptData["description"] as String,
        feature: feature,
        condition: condition,
      );
      pts.add(pt);
    }

    return pts;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelHeader(
            title: "Performative Transactions",
            onSort: () {},
          ),
          FutureBuilder<List<PerformativeTransaction>>(
            future: _ptFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final pts = snapshot.data ?? [];
                return CategorySection<PerformativeTransaction>(
                  categoryName: "All PTs",
                  items: pts,
                  itemBuilder: (ctx, pt) => DraggablePTItem(pt: pt),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
