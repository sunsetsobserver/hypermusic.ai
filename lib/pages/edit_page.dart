import 'package:flutter/material.dart';
import '../interfaces/data_interface.dart';
import '../models/feature.dart';
import '../registry/registry.dart';
import '../widgets/left_side_panel/left_side_panel.dart';
import '../widgets/feature_builder/feature_builder_panel.dart';
import '../top_nav_bar.dart';

class EditPage extends StatefulWidget {
  final DataInterface dataInterface;

  const EditPage({
    super.key,
    required this.dataInterface,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final GlobalKey<LeftSidePanelState> leftSidePanelKey = GlobalKey();
  Feature? _viewedFeature;
  Feature? _rootFeature;

  @override
  void initState() {
    super.initState();
    // Initialize with an empty root feature
    _rootFeature = Feature(
      name: "New Feature",
      description: "Default description",
      composites: [],
      transformationsMap: {},
    );
    _viewedFeature = _rootFeature;
  }

  void _handleFeatureStructureUpdated(Feature feature) {
    setState(() {
      _rootFeature = feature;
      if (_viewedFeature == null ||
          !_featureExistsInTree(_rootFeature!, _viewedFeature)) {
        _viewedFeature = _rootFeature;
      }
      // Refresh the left panel when feature structure changes
      leftSidePanelKey.currentState?.refreshFeatures();
    });
  }

  bool _featureExistsInTree(Feature root, Feature? candidate) {
    if (candidate == null) return false;
    if (candidate == root) return true;
    for (var c in root.composites) {
      if (_featureExistsInTree(c, candidate)) return true;
    }
    return false;
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
              dataInterface: widget.dataInterface,
              registry: widget.dataInterface as Registry,
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
              dataInterface: widget.dataInterface,
              onFeatureStructureUpdated: _handleFeatureStructureUpdated,
              onFeatureCompiled: () {
                leftSidePanelKey.currentState?.refreshFeatures();
              },
              viewedFeature: _viewedFeature,
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
