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
  Feature? _viewedFeature;
  Feature? _rootFeature;
  final GlobalKey<LeftSidePanelState> leftSidePanelKey =
      GlobalKey<LeftSidePanelState>();

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
        children: [
          SizedBox(
            width: 300,
            child: LeftSidePanel(
              key: leftSidePanelKey,
              dataInterface: widget.dataInterface,
              registry: widget.dataInterface as Registry,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: FeatureBuilderPanel(
              dataInterface: widget.dataInterface,
              onFeatureStructureUpdated: _handleFeatureStructureUpdated,
              onFeatureCompiled: () {
                // Refresh the left panel when a feature is compiled
                leftSidePanelKey.currentState?.refreshFeatures();
              },
              viewedFeature: _viewedFeature,
            ),
          ),
        ],
      ),
    );
  }
}
