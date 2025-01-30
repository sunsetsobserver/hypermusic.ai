import 'package:flutter/material.dart';

// Views
import 'package:hypermusic/view/widgets/top_nav_bar.dart';

class TradePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(showPagesLinks: true),
      body: Center(child: Text("Trade Page Content Here")),
    );
  }
}
