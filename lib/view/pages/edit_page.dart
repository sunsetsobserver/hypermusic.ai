import 'package:flutter/material.dart';

//Views
import 'package:hypermusic/view/widgets/left_side_panel/left_side_panel.dart';
import 'package:hypermusic/view/widgets/editor/feature/feature_builder_panel.dart';
import 'package:hypermusic/view/widgets/top_nav_bar.dart';

//Controllers
import 'package:hypermusic/controller/data_interface_controller.dart';
import 'package:hypermusic/controller/feature_editor_controller.dart';

class EditPage extends StatefulWidget {
  final DataInterfaceController dataInterfaceController;
  final FeatureEditorController featureEditorController;

  EditPage({super.key, required this.dataInterfaceController})
  : featureEditorController = FeatureEditorController();

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final GlobalKey<LeftSidePanelState> leftSidePanelKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(showPagesLinks: true),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: LeftSidePanel(
              dataInterfaceController: widget.dataInterfaceController,
              key: leftSidePanelKey,
            ),
          ),
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: FeatureBuilderPanel(
              dataInterfaceController: widget.dataInterfaceController,
              featureEditorController: widget.featureEditorController,
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey.withOpacity(0.05),
              child: const Center(
                child: Text(
                  'Placeholder for future content',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
