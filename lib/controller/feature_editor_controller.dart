import 'package:flutter/foundation.dart';

// Models
import 'package:hypermusic/model/feature.dart';

class FeatureEditorController extends ValueNotifier<Feature>
{
  FeatureEditorController() : super(
    Feature(
      name: "Root",
      description: "Root feature for composition",
      composites: [],
      transformationsMap: {},
    )
  );
}