import 'package:flutter/material.dart';
import 'feature_builder_workspace.dart';
import '../../interfaces/data_interface.dart';
import '../models/feature.dart';
import '../models/performative_transaction.dart';
import 'feature_tree_view.dart';

class FeatureBuilderPanel extends StatefulWidget {
  final DataInterface dataInterface;
  final VoidCallback onFeatureCompiled;

  const FeatureBuilderPanel({
    super.key,
    required this.dataInterface,
    required this.onFeatureCompiled,
  });

  @override
  State<FeatureBuilderPanel> createState() => _FeatureBuilderPanelState();
}

class _FeatureBuilderPanelState extends State<FeatureBuilderPanel> {
  final FeatureBuilderWorkspaceController _workspaceController =
      FeatureBuilderWorkspaceController();

  late Feature _rootContainerFeature;
  Feature? _viewedFeature;

  @override
  void initState() {
    super.initState();
    _rootContainerFeature = Feature(name: "New Feature");
    _viewedFeature = _rootContainerFeature;
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // When compiling, always use the full root tree (_rootContainerFeature)
                        final newName = await _showCompileDialog(context);
                        if (newName == null || newName.isEmpty) return;

                        final success =
                            await _workspaceController.compileWorkspace(
                          newName,
                          widget.dataInterface,
                          _rootContainerFeature, // Always compile from root
                        );

                        if (!mounted) return;

                        if (success) {
                          widget.onFeatureCompiled();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Feature "$newName" compiled successfully!'),
                            ),
                          );
                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content: Text('Compilation failed.')),
                          );
                        }
                      },
                      child: const Text("Compile"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _workspaceController.clearWorkspace();
                        setState(() {
                          _rootContainerFeature = Feature(name: "New Feature");
                          _viewedFeature = _rootContainerFeature;
                        });
                      },
                      child: const Text("Clear"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FeatureBuilderWorkspace(
                        controller: _workspaceController,
                        onTopLevelStructureAdded: (Feature f,
                            {PerformativeTransaction? pt}) {
                          // Just update state to rebuild tree
                          setState(() {});
                        },
                        onFeatureStructureUpdated: (Feature updatedRoot) {
                          setState(() {
                            _rootContainerFeature = updatedRoot;
                            // If viewedFeature was removed or changed, ensure it still exists
                            if (!_featureExistsInTree(
                                _rootContainerFeature, _viewedFeature)) {
                              _viewedFeature = _rootContainerFeature;
                            }
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 200,
                      color: Colors.white,
                      child: FeatureTreeView(
                        rootFeature: _rootContainerFeature,
                        viewedFeature: _viewedFeature,
                        onNodeSelected: (feature) {
                          // Only compound features are selectable
                          if (!feature.isScalar) {
                            setState(() {
                              _viewedFeature = feature;
                            });
                            _workspaceController.clearWorkspace();
                            _workspaceController
                                .displayFeature(_viewedFeature!);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _featureExistsInTree(Feature root, Feature? candidate) {
    if (candidate == null) return false;
    if (candidate == root) return true;
    for (var c in root.composites) {
      if (_featureExistsInTree(c, candidate)) return true;
    }
    return false;
  }

  Future<String?> _showCompileDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Compile New Feature"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Feature Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
              child: const Text("Compile"),
            ),
          ],
        );
      },
    );
  }
}
