import 'package:flutter/material.dart';
import '../interfaces/data_interface.dart';

class FeatureFetcherPage extends StatelessWidget {
  final DataInterface dataInterface;

  const FeatureFetcherPage({super.key, required this.dataInterface});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Fetcher'),
      ),
      body: Center(
        child: FutureBuilder<List<String>>(
          future: dataInterface.getAllFeatures(),
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
