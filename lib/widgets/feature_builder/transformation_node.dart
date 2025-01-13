// lib/widgets/feature_builder/transformation_node.dart
import 'package:flutter/material.dart';

class TransformationNode extends StatefulWidget {
  final String transformationName;
  final List<int> args;
  final void Function(List<int>)? onArgsChanged;

  const TransformationNode({
    super.key,
    required this.transformationName,
    required this.args,
    this.onArgsChanged,
  });

  @override
  State<TransformationNode> createState() => _TransformationNodeState();
}

class _TransformationNodeState extends State<TransformationNode> {
  late TextEditingController _argController;

  @override
  void initState() {
    super.initState();
    _argController = TextEditingController(
      text: widget.args.isNotEmpty ? widget.args[0].toString() : '0',
    );
  }

  @override
  void dispose() {
    _argController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TransformationNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.args != widget.args) {
      _argController.text =
          widget.args.isNotEmpty ? widget.args[0].toString() : '0';
    }
  }

  String _getTransformationDescription() {
    switch (widget.transformationName) {
      case "Add":
        return "Add ${widget.args.isNotEmpty ? widget.args[0] : 0} to index";
      case "Mul":
        return "Multiply index by ${widget.args.isNotEmpty ? widget.args[0] : 1}";
      case "Nop":
        return "No operation (pass through)";
      default:
        return "Unknown transformation";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.transformationName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _getTransformationDescription(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          if (widget.onArgsChanged != null &&
              widget.transformationName != "Nop") ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _argController,
                decoration: const InputDecoration(
                  labelText: 'Arg',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final intValue = int.tryParse(value);
                  if (intValue != null) {
                    widget.onArgsChanged!([intValue]);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
