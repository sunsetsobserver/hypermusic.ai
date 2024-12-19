import 'package:flutter/material.dart';
import '../models/transformation.dart';

class TransformationPropertyPanel extends StatefulWidget {
  final Transformation transformation;
  final void Function(Transformation updatedTransformation) onApply;
  final VoidCallback onCancel;

  const TransformationPropertyPanel({
    super.key,
    required this.transformation,
    required this.onApply,
    required this.onCancel,
  });

  @override
  State<TransformationPropertyPanel> createState() =>
      _TransformationPropertyPanelState();
}

class _TransformationPropertyPanelState
    extends State<TransformationPropertyPanel> {
  late TextEditingController _argController;

  @override
  void initState() {
    super.initState();
    // Assume the first arg is an integer
    final arg = widget.transformation.args.isNotEmpty
        ? widget.transformation.args[0]
        : 0;
    _argController = TextEditingController(text: arg.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // A Material widget for elevation and styling
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit ${widget.transformation.name}'),
            const SizedBox(height: 8),
            // Text field to edit the first argument
            TextField(
              controller: _argController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Argument',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onCancel();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Parse the argument
                    final argValue = int.tryParse(_argController.text) ?? 0;
                    final updatedTransformation = Transformation(
                      widget.transformation.name,
                      args: [argValue],
                    );
                    widget.onApply(updatedTransformation);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
