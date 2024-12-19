import 'package:flutter/material.dart';
import '../models/condition.dart';
import 'panel_header.dart';
import 'category_section.dart';
import 'draggable_condition_item.dart';
import '../../interfaces/data_interface.dart';

class ConditionListPanel extends StatefulWidget {
  final DataInterface dataInterface;

  const ConditionListPanel({super.key, required this.dataInterface});

  @override
  State<ConditionListPanel> createState() => _ConditionListPanelState();
}

class _ConditionListPanelState extends State<ConditionListPanel> {
  late Future<List<Condition>> _conditionsFuture;

  @override
  void initState() {
    super.initState();
    _conditionsFuture = _loadConditions();
  }

  Future<List<Condition>> _loadConditions() async {
    final conditionNames = await widget.dataInterface.getAllConditions();
    return conditionNames.map((name) => Condition(name)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelHeader(
            title: "Conditions",
            onSort: () {},
          ),
          FutureBuilder<List<Condition>>(
            future: _conditionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final conditions = snapshot.data ?? [];
                return CategorySection<Condition>(
                  categoryName: "All Conditions",
                  items: conditions,
                  itemBuilder: (ctx, cond) =>
                      DraggableConditionItem(condition: cond),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
