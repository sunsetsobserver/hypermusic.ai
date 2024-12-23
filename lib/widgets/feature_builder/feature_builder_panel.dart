import 'package:flutter/material.dart';
import 'feature_builder_workspace.dart';
import '../../interfaces/data_interface.dart';
import '../models/feature.dart';
import '../models/performative_transaction.dart';
import 'feature_tree_view.dart';
import '../models/feature_runner.dart';

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
  final FeatureRunner _runner = FeatureRunner();

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
                        final newName = await _showCompileDialog(context);
                        if (newName == null || newName.isEmpty) return;

                        final success =
                            await _workspaceController.compileWorkspace(
                          newName,
                          widget.dataInterface,
                          _rootContainerFeature,
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
                      onPressed: () async {
                        if (_viewedFeature == null) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('No feature selected to run.'),
                            ),
                          );
                          return;
                        }

                        // Run the feature with a default value of 1 if no howMany is specified
                        final results = _runner.runFeature(_viewedFeature!, 1);
                        _runner.printResults(results);

                        // Show results in a dialog
                        if (!mounted) return;
                        await _showResultsDialog(context, results);
                      },
                      child: const Text("Run Feature"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: FeatureBuilderWorkspace(
                        controller: _workspaceController,
                        onTopLevelStructureAdded: (Feature f,
                            {PerformativeTransaction? pt}) {
                          setState(() {});
                        },
                        onFeatureStructureUpdated: (Feature updatedRoot) {
                          setState(() {
                            _rootContainerFeature = updatedRoot;
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
                          if (!feature.isScalar) {
                            setState(() {
                              _viewedFeature = feature;
                            });
                            _workspaceController.clearWorkspace();
                            _workspaceController.displayFeature(
                              _viewedFeature!,
                              parent: _rootContainerFeature,
                            );
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
          title: const Text("Compile Feature"),
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
              onPressed: () => Navigator.pop(ctx, nameController.text),
              child: const Text("Compile"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResultsDialog(
      BuildContext context, List<List<int>> results) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Feature Results"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < results.length; i++)
                  Text("Step $i: ${results[i]}"),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
