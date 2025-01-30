import 'package:flutter/material.dart';

// Controllers
import 'package:hypermusic/controller/data_interface_controller.dart';

class FeatureFetcherPage extends StatelessWidget {
  
  final DataInterfaceController dataInterfaceController;

  const FeatureFetcherPage({super.key, required this.dataInterfaceController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Fetcher'),
      ),
      body: Center(
        child: FutureBuilder<List<String>>(
          future: dataInterfaceController.getAllFeatureNames(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final features = snapshot.data ?? [];
              return ListView.builder(
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(features[index]),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
