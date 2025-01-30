import 'package:flutter/material.dart';
import '../../../controller/data_interface_controller.dart';
import '../../../model/condition.dart';
import '../draggable/draggable_condition_item.dart';

class ConditionListPanel extends StatelessWidget {
  final DataInterfaceController dataInterfaceController;

  const ConditionListPanel({
    super.key,
    required this.dataInterfaceController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(2.0),
      ),
      margin: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              'Conditions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: FutureBuilder<List<String>>(
              future: dataInterfaceController.getAllConditions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'No conditions available',
                      style: TextStyle(fontSize: 11),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(4.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final conditionName = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: DraggableConditionItem(
                        condition: Condition(
                          name: conditionName,
                          description:
                              '', // Empty description as it's not shown in UI
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
