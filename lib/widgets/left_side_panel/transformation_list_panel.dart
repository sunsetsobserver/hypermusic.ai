import 'package:flutter/material.dart';
import '../models/transformation.dart';
import 'panel_header.dart';
import 'category_section.dart';
import 'draggable_transformation_item.dart';
import '../../interfaces/data_interface.dart';

class TransformationListPanel extends StatefulWidget {
  final DataInterface dataInterface;

  const TransformationListPanel({super.key, required this.dataInterface});

  @override
  State<TransformationListPanel> createState() =>
      _TransformationListPanelState();
}

class _TransformationListPanelState extends State<TransformationListPanel> {
  late Future<List<Transformation>> _transformationsFuture;

  @override
  void initState() {
    super.initState();
    _transformationsFuture = _loadTransformations();
  }

  Future<List<Transformation>> _loadTransformations() async {
    // Directly call the method from dataInterface
    final transformationNames =
        await widget.dataInterface.getAllTransformations();
    return transformationNames.map((name) => Transformation(name)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelHeader(
            title: "Transformations",
            onSort: () {},
          ),
          FutureBuilder<List<Transformation>>(
            future: _transformationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final transformations = snapshot.data ?? [];
                return CategorySection<Transformation>(
                  categoryName: "All Transformations",
                  items: transformations,
                  itemBuilder: (ctx, trans) =>
                      DraggableTransformationItem(transformation: trans),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
