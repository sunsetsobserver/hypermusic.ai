// lib/widgets/left_side_panel/feature_list_panel.dart

import 'package:flutter/material.dart';
import '../models/feature.dart';
import '../models/transformation.dart';
import 'panel_header.dart';
import 'category_section.dart';
import 'draggable_feature_item.dart';
import '../../interfaces/data_interface.dart';
import '../../mock/user_toolbox.dart';

class FeatureListPanel extends StatefulWidget {
  final DataInterface dataInterface;

  const FeatureListPanel({super.key, required this.dataInterface});

  @override
  State<FeatureListPanel> createState() => _FeatureListPanelState();
}

class _FeatureListPanelState extends State<FeatureListPanel> {
  Future<Feature> _parseFeature(Map<dynamic, dynamic> data) async {
    // Parse composites
    List<Feature> compositeFeatures = [];
    for (final cName in (data["composites"] as List)) {
      final cData = await widget.dataInterface.getFeature(cName as String);
      final cFeature = await _parseFeature(cData);
      compositeFeatures.add(cFeature);
    }

    // Parse transformations
    Map<String, List<Transformation>> transformationsMap = {};
    if (data["transformations"] != null) {
      for (final t in data["transformations"] as List) {
        final tMap = t as Map<dynamic, dynamic>;
        final subFeatureName = tMap["subFeatureName"] as String;
        final transformation = Transformation(
          tMap["name"] as String,
          args: List<dynamic>.from(tMap["args"] as List),
        );

        if (!transformationsMap.containsKey(subFeatureName)) {
          transformationsMap[subFeatureName] = [];
        }
        transformationsMap[subFeatureName]!.add(transformation);
      }
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

  Future<List<Feature>> _loadFeatures() async {
    final featureNames = await widget.dataInterface.getAllFeatures();
    List<Feature> features = [];
    for (final name in featureNames) {
      final fData = await widget.dataInterface.getFeature(name);
      final feature = await _parseFeature(fData);
      features.add(feature);
    }
    return features;
  }

  Future<void> _removeFeature(String name) async {
    UserToolbox.removeFeature(name);
    setState(() {}); // Refresh the list
  }

  @override
  Widget build(BuildContext context) {
    final futureFeatures = _loadFeatures();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<List<Feature>>(
        future: futureFeatures,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final features = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PanelHeader(
                title: "Features",
                onSort: () {
                  // Implement sorting if needed.
                },
              ),
              CategorySection<Feature>(
                categoryName: "All Features",
                items: features,
                itemBuilder: (ctx, feature) => DraggableFeatureItem(
                  feature: feature,
                  dataInterface: widget.dataInterface,
                  onFeatureRemoved: () => _removeFeature(feature.name),
                  onFeatureAdded: () => setState(() {}),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
