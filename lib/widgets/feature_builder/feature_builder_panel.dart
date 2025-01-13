import 'package:flutter/material.dart';
import '../../models/feature.dart';
import '../../interfaces/data_interface.dart';
import 'feature_tree_editor.dart';

class FeatureBuilderPanel extends StatefulWidget {
  final DataInterface dataInterface;
  final Function(Feature) onFeatureStructureUpdated;
  final VoidCallback onFeatureCompiled;
  final Feature? viewedFeature;

  const FeatureBuilderPanel({
    super.key,
    required this.dataInterface,
    required this.onFeatureStructureUpdated,
    required this.onFeatureCompiled,
    this.viewedFeature,
  });

  @override
  State<FeatureBuilderPanel> createState() => _FeatureBuilderPanelState();
}

class _FeatureBuilderPanelState extends State<FeatureBuilderPanel> {
  final TextEditingController _nameController = TextEditingController();
  bool _isBuilding = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.viewedFeature?.name ?? '';
  }

  @override
  void didUpdateWidget(FeatureBuilderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewedFeature != widget.viewedFeature) {
      _nameController.text = widget.viewedFeature?.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleBuild() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for the feature'),
        ),
      );
      return;
    }

    setState(() {
      _isBuilding = true;
    });

    try {
      if (widget.viewedFeature == null) {
        throw Exception('No feature to build');
      }

      final rootFeature = widget.viewedFeature!;

      await widget.dataInterface.registerFeature(
        _nameController.text,
        rootFeature.composites.map((f) => f.name).toList(),
        rootFeature.transformationsMap.entries.expand((entry) {
          return entry.value.map((t) => {
                'subFeatureName': entry.key,
                ...t,
              });
        }).toList(),
      );

      widget.onFeatureStructureUpdated(rootFeature);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feature built successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error building feature: ${e.toString()}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBuilding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(
                      labelText: 'Feature Name',
                      labelStyle: TextStyle(fontSize: 11),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: _isBuilding ? null : _handleBuild,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  child: _isBuilding
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Build'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: widget.viewedFeature != null
              ? FeatureTreeEditor(
                  rootFeature: widget.viewedFeature!,
                  onFeatureUpdate: widget.onFeatureStructureUpdated,
                )
              : const Center(
                  child: Text(
                    'No feature selected',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
        ),
      ],
    );
  }
}
