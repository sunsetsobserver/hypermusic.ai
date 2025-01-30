import 'package:flutter/material.dart';

// Views
import 'package:hypermusic/view/widgets/left_side_panel/feature_list_panel.dart';
import 'package:hypermusic/view/widgets/left_side_panel/transformation_list_panel.dart';
import 'package:hypermusic/view/widgets/left_side_panel/condition_list_panel.dart';

// Controllers
import 'package:hypermusic/controller/data_interface_controller.dart';

class LeftSidePanel extends StatefulWidget {

  final DataInterfaceController dataInterfaceController;

  const LeftSidePanel({
    super.key,
    required this.dataInterfaceController,
  });

  @override
  State<LeftSidePanel> createState() => LeftSidePanelState();
}

class LeftSidePanelState extends State<LeftSidePanel> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey[50],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeatureListPanel(
              dataInterfaceController: widget.dataInterfaceController,
            ),
            const SizedBox(height: 4),
            TransformationListPanel(
              dataInterfaceController: widget.dataInterfaceController,
            ),
            const SizedBox(height: 4),
            ConditionListPanel(
              dataInterfaceController: widget.dataInterfaceController,
            ),
          ],
        ),
      ),
    );
  }
}
