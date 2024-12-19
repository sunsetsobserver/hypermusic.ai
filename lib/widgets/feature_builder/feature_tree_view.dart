import 'package:flutter/material.dart';
import '../models/feature.dart';

class FeatureTreeView extends StatelessWidget {
  final Feature rootFeature;
  final Feature? viewedFeature;
  final ValueChanged<Feature> onNodeSelected;

  const FeatureTreeView({
    super.key,
    required this.rootFeature,
    required this.onNodeSelected,
    required this.viewedFeature,
  });

  @override
  Widget build(BuildContext context) {
    // Make the tree horizontally scrollable as well to prevent overflow
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: _FeatureNodeView(
          feature: rootFeature,
          onNodeSelected: onNodeSelected,
          viewedFeature: viewedFeature,
          isRoot: true,
        ),
      ),
    );
  }
}

class _FeatureNodeView extends StatefulWidget {
  final Feature feature;
  final ValueChanged<Feature> onNodeSelected;
  final Feature? viewedFeature;
  final bool isRoot;

  const _FeatureNodeView({
    required this.feature,
    required this.onNodeSelected,
    required this.viewedFeature,
    this.isRoot = false,
  });

  @override
  State<_FeatureNodeView> createState() => _FeatureNodeViewState();
}

class _FeatureNodeViewState extends State<_FeatureNodeView> {
  bool _isHovering = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final feature = widget.feature;
    final isScalar = feature.isScalar;
    final isSelected = widget.viewedFeature == feature && !isScalar;
    final isRoot = widget.isRoot;

    Color bulletColor;
    Widget bulletIcon;

    if (isScalar) {
      // Scalar feature: black dot, not clickable, no hover effect.
      bulletColor = Colors.black;
      bulletIcon = Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: bulletColor, shape: BoxShape.circle));
    } else {
      // Compound feature: triangle
      // If selected: bullet is blue, else black
      bulletColor = isSelected ? Colors.blue : Colors.black;
      // Show ► if collapsed, ▼ if expanded
      bulletIcon = Text(
        _isExpanded ? "▼" : "►",
        style: TextStyle(color: bulletColor, fontWeight: FontWeight.bold),
      );
    }

    // If selectable (compound), change text color on hover to grey
    Color textColor;
    if (!isScalar && _isHovering) {
      textColor = Colors.grey;
    } else {
      textColor = Colors.black;
    }

    String displayName = isRoot ? "New Feature" : feature.name;

    Widget titleRow = Row(
      children: [
        bulletIcon,
        const SizedBox(width: 8),
        Text(displayName, style: TextStyle(color: textColor)),
      ],
    );

    // If scalar, no gestures and no expansion
    if (isScalar) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: titleRow,
      );
    }

    // Compound feature (selectable)
    // Wrap in MouseRegion for hover effect
    Widget selectableTitle = MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          // On tap, show this feature in the workspace
          widget.onNodeSelected(feature);
          // Toggle expansion to visualize children
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: titleRow,
      ),
    );

    if (feature.composites.isEmpty) {
      // No children, but compound means it had transformations/dimensions?
      // Actually if isRoot "New Feature" and no composites, it's still scalar logically,
      // but let's say if name != "New Feature" and no composites but not scalar is a rare case.
      // If no composites, treat as scalar? Or just allow clicking to select?
      // According to rules, a feature with no composites is scalar, so this situation shouldn't happen.
      // We'll show no children anyway.
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: selectableTitle,
      );
    }

    // Has children (composite)
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          selectableTitle,
          if (_isExpanded)
            ...feature.composites.map((c) => _FeatureNodeView(
                  feature: c,
                  onNodeSelected: widget.onNodeSelected,
                  viewedFeature: widget.viewedFeature,
                  isRoot: false,
                ))
        ],
      ),
    );
  }
}
