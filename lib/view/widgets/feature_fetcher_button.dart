import 'package:flutter/material.dart';

// Views
import 'package:hypermusic/view/pages/feature_fetcher_page.dart';

// Controllers
import 'package:hypermusic/controller/data_interface_controller.dart';


class FeatureFetcherButton extends StatelessWidget {

  final DataInterfaceController dataInterfaceController;

  FeatureFetcherButton({super.key, required this.dataInterfaceController});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.folder_open),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeatureFetcherPage(dataInterfaceController: dataInterfaceController),
          ),
        );
      },
    );
  }
}
