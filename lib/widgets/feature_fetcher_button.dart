import 'package:flutter/material.dart';
import '../registry/registry.dart';
import 'feature_fetcher_page.dart';

class FeatureFetcherButton extends StatelessWidget {
  final Registry registry = Registry();

  FeatureFetcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.folder_open),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeatureFetcherPage(dataInterface: registry),
          ),
        );
      },
    );
  }
}
