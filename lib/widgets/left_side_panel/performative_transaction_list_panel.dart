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

  Future<Feature> _parseFeature(Map<String, dynamic> data) async {
    List<Feature> compositeFeatures = [];
    for (final cName in (data["composites"] as List)) {
      final cData = await widget.dataInterface.getFeature(cName);
      final cFeature = await _parseFeature(cData);
      compositeFeatures.add(cFeature);
    }

    List<List<Transformation>> transformations = [];
    for (final dim in (data["transformations"] as List)) {
      List<Transformation> dimTransforms = [];
      for (final tData in (dim as List)) {
        dimTransforms.add(Transformation(tData["name"], args: tData["args"]));
      }
      transformations.add(dimTransforms);
    }

    return Feature(
      name: data["name"],
      composites: compositeFeatures,
      transformations: transformations,
    );
  }

  Future<List<PerformativeTransaction>> _loadPerformativeTransactions() async {
    final ptNames = await widget.dataInterface.getAllPerformativeTransactions();
    List<PerformativeTransaction> pts = [];

    for (final ptName in ptNames) {
      final ptData =
          await widget.dataInterface.getPerformativeTransaction(ptName);
      // ptData: { "name": ..., "description": ..., "feature": "FeatureB", "condition": "ConditionA" }

      // Parse condition
      final conditionData =
          await widget.dataInterface.getCondition(ptData["condition"]);
      final condition = Condition(conditionData["name"],
          description: conditionData["description"]);

      // Parse feature
      final featureData =
          await widget.dataInterface.getFeature(ptData["feature"]);
      final feature = await _parseFeature(featureData);

      final pt = PerformativeTransaction(
        name: ptData["name"],
        description: ptData["description"],
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
