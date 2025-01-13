import 'package:flutter/material.dart';
import '../../models/running_instance.dart';

class RunningInstanceEditor extends StatefulWidget {
  final RunningInstance instance;
  final Function(RunningInstance) onUpdate;

  const RunningInstanceEditor({
    super.key,
    required this.instance,
    required this.onUpdate,
  });

  @override
  State<RunningInstanceEditor> createState() => _RunningInstanceEditorState();
}

class _RunningInstanceEditorState extends State<RunningInstanceEditor> {
  late TextEditingController _startPointController;
  late TextEditingController _startIndexController;
  late TextEditingController _endIndexController;

  @override
  void initState() {
    super.initState();
    _startPointController =
        TextEditingController(text: widget.instance.startPoint.toString());
    _startIndexController = TextEditingController(
        text: widget.instance.transformationStartIndex.toString());
    _endIndexController = TextEditingController(
        text: widget.instance.transformationEndIndex.toString());
  }

  @override
  void dispose() {
    _startPointController.dispose();
    _startIndexController.dispose();
    _endIndexController.dispose();
    super.dispose();
  }

  void _updateStartPoint(String value) {
    final startPoint = int.tryParse(value) ?? 0;
    widget.onUpdate(widget.instance.copyWith(startPoint: startPoint));
  }

  void _updateTransformationRange(String? startValue, String? endValue) {
    final startIndex = startValue != null ? int.tryParse(startValue) : null;
    final endIndex = endValue != null ? int.tryParse(endValue) : null;

    widget.onUpdate(
      widget.instance.copyWith(
        transformationStartIndex:
            startIndex ?? widget.instance.transformationStartIndex,
        transformationEndIndex:
            endIndex ?? widget.instance.transformationEndIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.instance.feature.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(widget.instance.feature.description),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Starting Point: '),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _startPointController,
                keyboardType: TextInputType.number,
                onChanged: _updateStartPoint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Transformation Range: '),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _startIndexController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateTransformationRange(value, null),
              ),
            ),
            const Text(' to '),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _endIndexController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateTransformationRange(null, value),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
