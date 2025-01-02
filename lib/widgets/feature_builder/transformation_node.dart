// lib/widgets/feature_builder/transformation_node.dart
import 'package:flutter/material.dart';

class TransformationNode extends StatefulWidget {
  final String transformationName;
  final List<dynamic> args;
  final void Function(List<dynamic>)? onArgsChanged;

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
        return widget.transformationName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const Icon(Icons.settings, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _getTransformationDescription(),
              style: TextStyle(
                fontSize: 12,
                color:
                    widget.onArgsChanged == null ? Colors.grey : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (widget.onArgsChanged != null)
            SizedBox(
              width: 50,
              height: 24,
              child: TextField(
                controller: _argController,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                enabled: widget.onArgsChanged != null,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 12),
                onChanged: (value) {
                  final intValue = int.tryParse(value) ?? 0;
                  widget.onArgsChanged?.call([intValue]);
                },
              ),
            ),
        ],
      ),
    );
  }
}
