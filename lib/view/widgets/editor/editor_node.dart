import 'package:flutter/material.dart';

// Views
import 'package:hypermusic/view/widgets/editor/running_instance/running_instance_editor.dart';

//Controllers
import 'package:hypermusic/controller/feature_editor_controller.dart';
import 'package:hypermusic/controller/running_instance_editor_controller.dart';

class EditorNode extends StatelessWidget {

  final bool isExpanded;

  final FeatureEditorController featureEditorController;
  final RunningInstanceEditorController runningInstanceEditorController;

  const EditorNode({
    super.key,
    required this.featureEditorController,
    required this.runningInstanceEditorController,
  }) : isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        featureEditorController.value.name,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    // if (onRemove != null)
                    //   MouseRegion(
                    //     cursor: SystemMouseCursors.click,
                    //     child: GestureDetector(
                    //       onTap: onRemove,
                    //       child: Icon(
                    //         Icons.close,
                    //         size: 12,
                    //         color: Colors.grey.withOpacity(0.7),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RunningInstanceEditor( runningInstanceEditorController: runningInstanceEditorController,)
                    ],
                  ),
                  // if (instance.feature.condition.isNotEmpty) ...[
                  //   const SizedBox(height: 4),
                  //   Text(
                  //     'if ${instance.feature.condition}',
                  //     style: const TextStyle(
                  //       fontSize: 12,
                  //       fontStyle: FontStyle.italic,
                  //     ),
                  //   ),
                  // ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
