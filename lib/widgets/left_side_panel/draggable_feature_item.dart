// lib/widgets/left_side_panel/draggable_feature_item.dart
import 'package:flutter/material.dart';
import '../models/feature.dart';
import '../../interfaces/data_interface.dart';

class DraggableFeatureItem extends StatelessWidget {
  final Feature feature;
  final DataInterface dataInterface;
  final VoidCallback onFeatureRemoved;
  final VoidCallback onFeatureAdded;

  const DraggableFeatureItem({
    super.key,
    required this.feature,
    required this.dataInterface,
    required this.onFeatureRemoved,
    required this.onFeatureAdded,
  });

  Future<void> _showCopyDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Copy Feature"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'New Feature Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, nameController.text),
              child: const Text("Copy"),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      final copiedFeature = feature.copyWithNewName(newName);
      await _registerFeatureRecursively(copiedFeature);

      // Show a success message and trigger a UI refresh
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feature "$newName" copied successfully!'),
          ),
        );
        onFeatureAdded();
      }
    }
  }

  Future<void> _registerFeatureRecursively(Feature feature) async {
    // First register all sub-features
    for (var composite in feature.composites) {
      await _registerFeatureRecursively(composite);
    }

    // Then register this feature
    final featureData = _serializeFeature(feature);
    await dataInterface.registerFeature(
      feature.name,
      featureData["composites"] as List<String>,
      featureData["transformations"] as List<Map<String, dynamic>>,
      startingPoints: featureData["startingPoints"] as Map<String, dynamic>,
      howManyValues: featureData["howManyValues"] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> _serializeFeature(Feature feature) {
    // Collect all transformations for this feature
    List<Map<String, dynamic>> allTransformations = [];
    for (final entry in feature.transformationsMap.entries) {
      for (final trans in entry.value) {
        allTransformations.add({
          "subFeatureName": entry.key,
          "name": trans.name,
          "args": trans.args,
        });
      }
    }

    return {
      "name": feature.name,
      "composites": feature.composites.map((c) => c.name).toList(),
      "transformations": allTransformations,
      "startingPoints": feature.startingPoints,
      "howManyValues": feature.howManyValues,
      "subFeatures":
          feature.composites.map((c) => _serializeFeature(c)).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<Feature>(
      data: feature,
      feedback: _buildDragFeedback(context),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildItem(context),
      ),
      child: _buildItem(context),
    );
  }

  Widget _buildItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.music_note, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(feature.name)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) async {
              switch (value) {
                case 'copy':
                  await _showCopyDialog(context);
                case 'remove':
                  onFeatureRemoved();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 8),
                    Text('Copy'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove from Toolbox',
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDragFeedback(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue[100],
        child: Row(
          children: [
            const Icon(Icons.music_note, size: 20),
            const SizedBox(width: 8),
            Text(feature.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
