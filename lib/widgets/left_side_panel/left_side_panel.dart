import 'package:flutter/material.dart';
import '../../interfaces/data_interface.dart';
import '../../registry/registry.dart';
import 'feature_list_panel.dart';
import 'transformation_list_panel.dart';
import 'condition_list_panel.dart';

class LeftSidePanel extends StatefulWidget {
  final DataInterface dataInterface;
  final Registry registry;

  const LeftSidePanel({
    super.key,
    required this.dataInterface,
    required this.registry,
  });

  @override
  State<LeftSidePanel> createState() => LeftSidePanelState();
}

class LeftSidePanelState extends State<LeftSidePanel> {
  void refreshFeatures() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeatureListPanel(
              registry: widget.registry,
            ),
            const SizedBox(height: 16),
            TransformationListPanel(
              dataInterface: widget.dataInterface,
            ),
            const SizedBox(height: 16),
            ConditionListPanel(
              dataInterface: widget.dataInterface,
            ),
          ],
        ),
      ),
    );
  }
}
