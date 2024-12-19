import 'package:flutter/material.dart';
import '../top_nav_bar.dart';
import '../widgets/left_side_panel/left_side_panel.dart';
import '../widgets/feature_builder/feature_builder_panel.dart';
import '../../mock/mock_api.dart';
import '../../interfaces/data_interface.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final DataInterface dataInterface = MockAPI();
  // A global key to access the LeftSidePanel state.
  final GlobalKey<LeftSidePanelState> leftSidePanelKey =
      GlobalKey<LeftSidePanelState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(showPagesLinks: true),
      body: Row(
        children: [
          SizedBox(
            width: 300,
            // Pass the key to LeftSidePanel to later call refreshFeatures
            child: LeftSidePanel(
              key: leftSidePanelKey,
              dataInterface: dataInterface,
            ),
          ),
          Expanded(
            // Pass a callback to FeatureBuilderPanel that calls refreshFeatures on the left panel
            child: FeatureBuilderPanel(
              dataInterface: dataInterface,
              onFeatureCompiled: () {
                // When a feature is compiled, refresh the left side panel
                leftSidePanelKey.currentState?.refreshFeatures();
              },
            ),
          ),
        ],
      ),
    );
  }
}
