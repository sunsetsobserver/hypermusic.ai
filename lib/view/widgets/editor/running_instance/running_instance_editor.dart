import 'package:flutter/material.dart';

// Controllers
import 'package:hypermusic/controller/running_instance_editor_controller.dart';

class RunningInstanceEditor extends StatefulWidget {

  final RunningInstanceEditorController runningInstanceEditorController;

  const RunningInstanceEditor({super.key, required this.runningInstanceEditorController,});

  @override
  State<RunningInstanceEditor> createState() => _RunningInstanceEditorState();
}

class _RunningInstanceEditorState extends State<RunningInstanceEditor> {

  late TextEditingController _startPointController;
  late TextEditingController _transformationStartIndexController;
  late TextEditingController _transformationEndIndexController;

  @override
  void initState() {
    super.initState();
    final runningInstance = widget.runningInstanceEditorController.value;

    _startPointController = TextEditingController(text: runningInstance.startPoint.toString());
    _transformationStartIndexController = TextEditingController(text: runningInstance.transformationStartIndex.toString());
    _transformationEndIndexController = TextEditingController(text: runningInstance.transformationEndIndex.toString());

    final instance = widget.runningInstanceEditorController.value;

    _startPointController.addListener(  
      () => instance.copyWith(startPoint: int.tryParse(_startPointController.text) ?? 0)
    );

    _transformationStartIndexController.addListener(
      () => instance.copyWith(transformationStartIndex: int.tryParse(_transformationStartIndexController.text) ?? 0)
    );

    _transformationEndIndexController.addListener(
      () => instance.copyWith(transformationEndIndex: int.tryParse(_transformationEndIndexController.text) ?? 0)
    );
  }

  @override
  void dispose() {
    _startPointController.dispose();
    _transformationStartIndexController.dispose();
    _transformationEndIndexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                controller: _transformationStartIndexController,
                keyboardType: TextInputType.number,
              ),
            ),
            const Text(' to '),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _transformationEndIndexController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
