import 'package:flutter/material.dart';
import 'feature_list_panel.dart';
import 'transformation_list_panel.dart';
import 'condition_list_panel.dart';
import 'performative_transaction_list_panel.dart';
import '../../interfaces/data_interface.dart';

class LeftSidePanel extends StatefulWidget {
  final DataInterface dataInterface;

  const LeftSidePanel({super.key, required this.dataInterface});

  @override
  LeftSidePanelState createState() => LeftSidePanelState();
}

class LeftSidePanelState extends State<LeftSidePanel> {
  // We can store any state related to the lists here if needed.

  void refreshFeatures() {
    // Trigger a rebuild. If FeatureListPanel fetches data on build or via FutureBuilder,
    // it will re-fetch the data and update.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeatureListPanel(dataInterface: widget.dataInterface),
          const SizedBox(height: 16),
          TransformationListPanel(dataInterface: widget.dataInterface),
          const SizedBox(height: 16),
          ConditionListPanel(dataInterface: widget.dataInterface),
          const SizedBox(height: 16),
          PerformativeTransactionListPanel(dataInterface: widget.dataInterface),
        ],
      ),
    );
  }
}
