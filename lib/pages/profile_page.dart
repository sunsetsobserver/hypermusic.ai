import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meta_mask_provider.dart';
import '../top_nav_bar.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final metaMask = Provider.of<MetaMaskProvider>(context);

    return Scaffold(
      appBar: TopNavBar(showPagesLinks: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${metaMask.currentAddress}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'This is your profile page.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
