import 'package:flutter/material.dart';
import '../../interfaces/data_interface.dart';
import '../../models/transformation.dart';

class TransformationListPanel extends StatelessWidget {
  final DataInterface dataInterface;

  const TransformationListPanel({
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
              'Transformations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: FutureBuilder<List<String>>(
                future: dataInterface.getAllTransformations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Text('No transformations available'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final transformationName = snapshot.data![index];
                      return Draggable<Transformation>(
                        data: Transformation(
                          transformationName,
                          args: [0], // Default argument
                        ),
                        feedback: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              transformationName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(transformationName),
                          dense: true,
                          trailing: const Icon(Icons.drag_handle, size: 16),
                        ),
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
