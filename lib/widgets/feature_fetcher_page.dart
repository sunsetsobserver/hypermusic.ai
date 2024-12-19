import 'package:flutter/material.dart'; //flutter’s Material Design widgets and theme
import '../interfaces/data_interface.dart';
import '../mock/mock_api.dart';

class FeatureFetcherPage extends StatefulWidget {
  @override
  FeatureFetcherPageState createState() => FeatureFetcherPageState();
}

class FeatureFetcherPageState extends State<FeatureFetcherPage> {
  final DataInterface api = MockAPI(); // Use MockAPI for development
  List<String> features = [];

  @override
  void initState() {
    super.initState();
    fetchFeatures(); // Fetch features when the widget is initialized
  }

  void fetchFeatures() async {
    final fetchedFeatures = await api.getAllFeatures();
    setState(() {
      features = fetchedFeatures;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Features')),
      body: Center(
        child: features.isEmpty
            ? CircularProgressIndicator() // Show a loading spinner
            : ListView.builder(
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(features[index]),
                  );
                },
              ),
      ),
    );
  }
}
