import 'package:flutter/material.dart';
import '../../interfaces/data_interface.dart';

class ConditionListPanel extends StatelessWidget {
  final DataInterface dataInterface;

  const ConditionListPanel({
    super.key,
    required this.dataInterface,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Conditions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: FutureBuilder<List<String>>(
                future: dataInterface.getAllConditions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No conditions available'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final condition = snapshot.data![index];
                      return ListTile(
                        title: Text(condition),
                        dense: true,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
