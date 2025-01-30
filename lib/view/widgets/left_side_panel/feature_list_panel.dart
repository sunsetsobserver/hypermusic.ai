import 'package:flutter/material.dart';

//Views
import 'package:hypermusic/view/widgets/draggable/draggable_feature_item.dart';

// Controllers
import 'package:hypermusic/controller/data_interface_controller.dart';

class FeatureListPanel extends StatelessWidget {
  final DataInterfaceController dataInterfaceController;

  const FeatureListPanel({
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
              'Features',
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
            // asynchronous fetch feature names from dataInterfaceController 
            child: FutureBuilder<List<String>>(
              future: dataInterfaceController.getAllFeatureNames(),
              builder: (context, snapshot) {
                // still fetching...
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } // handle error when connecting to dataInterfaceController
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } // when asynchronous operation completed, display features
                else {
                  return ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(4.0),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: DraggableFeatureItem(feature: dataInterfaceController.getNewestFeature(snapshot.data![index])!),
                      );
                    },
                  );
                }
              },
            ) 
          ),
        ],
      ),
    );
  }
}
