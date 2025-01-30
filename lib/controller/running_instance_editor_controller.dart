import 'package:flutter/foundation.dart';

// Models
import 'package:hypermusic/model/running_instance.dart';

class RunningInstanceEditorController extends ValueNotifier<RunningInstance>
{
  RunningInstanceEditorController() : super(
    RunningInstance(
      startPoint: 0,
      howManyValues: 0,
      transformationStartIndex: 0,
      transformationEndIndex: 0,
    )
  );
}