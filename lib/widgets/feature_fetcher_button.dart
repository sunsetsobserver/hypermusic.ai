import 'package:flutter/material.dart';
import '../interfaces/data_interface.dart';
import '../mock/mock_api.dart';

class FeatureFetcherButton extends StatelessWidget {
  final DataInterface api = MockAPI(); // Use MockAPI for development

  void fetchFeatures() async {
    final features = await api.getAllFeatures();
    print("Features: $features");
  }

  @override
  Widget build(BuildContext context) {
    // Just return a button here, no Scaffold needed
    return ElevatedButton(
      onPressed: fetchFeatures,
      child: Text('Fetch Features'),
    );
  }
}
