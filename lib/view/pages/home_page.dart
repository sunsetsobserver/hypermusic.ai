import 'package:flutter/material.dart'; //Flutter material widget library
import 'package:provider/provider.dart'; //access and watch the MetaMaskProvider state using the Provider package

// Providers
import 'package:hypermusic/providers/meta_mask_provider.dart';

// Views
import 'package:hypermusic/view/pages/feature_fetcher_page.dart';
import 'package:hypermusic/view/widgets/feature_fetcher_button.dart';
import 'package:hypermusic/view/widgets/typewriter_text.dart';
import 'package:hypermusic/view/widgets/top_nav_bar.dart';

// Controllers
import 'package:hypermusic/controller/data_interface_controller.dart';

class HomePage extends StatelessWidget 
{
  final DataInterfaceController dataInterfaceController;

  //contains the phrases that TypewriterText will cycle through.
  //These strings describe the vision or theme of the app:
  final List<String> typewriterTexts = [
    "Become a part of music's connected future.",
    "Join a creative network of human and post-human creators.",
    "Imagine a collective musical intelligence.",
    "Explore the potential of interconnected musical structures."
  ];

 HomePage({super.key, required this.dataInterfaceController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Material Design layout structure
      backgroundColor: Colors.white,
      //sets the page’s background to white
      appBar: TopNavBar(showPagesLinks: false),
      // places a custom navigation bar at the top without showing the pages links (just the branding, wallet connect button, etc.)
      body: SingleChildScrollView(
        //wraps the main content in a scrollable area, so if the screen is small, the user can scroll
        child: Container(
          //ensures the content stretches to the full width of the screen
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          //adds horizontal padding for a nicer layout
          child: Column(
            //organizes the page elements vertically
            mainAxisAlignment: MainAxisAlignment.center,
            //centers the column’s children vertically if there’s room
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              //creates a vertical space equal to 15% of the screen’s height, pushing content down from the top
              TypewriterText(
                //display the typewriterTexts list in a typewriter fashion
                texts: typewriterTexts,
                period: Duration(milliseconds: 2000),
                //after finishing typing a text, it will wait 2 seconds before starting to delete it and then move on to the next phrase
              ),
              const SizedBox(height: 50),
              //adds space after the typewriter text for separation
              Text(
                //secondary heading under the typewriter text:
                'Rethink music making with hypermusic.ai',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                //This button is for connecting to MetaMask or navigating if already connected
                onPressed: () async {
                  final metaMask =
                      Provider.of<MetaMaskProvider>(context, listen: false);
                  // obtains the MetaMaskProvider instance without listening to changes (just a one-time access)
                  if (metaMask.isConnected) {
                    //If connected, it navigates directly to /explore
                    Navigator.pushNamed(context, '/explore');
                  } else {
                    //If not connected but isEnabled (MetaMask is available), it attempts to connect by calling metaMask.connect().
                    if (metaMask.isEnabled) {
                      await metaMask.connect();
                      if (context.mounted) {
                        //If successful and still mounted (the page is still displayed), it navigates to /explore
                        Navigator.pushNamed(context, '/explore');
                      }
                    } else {
                      //If not enabled, it shows a SnackBar message indicating MetaMask isn’t available
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "MetaMask is not available in this browser.")),
                      );
                    }
                  }
                },
                child: Text("Enter", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 50),
              //after the button adds some breathing room at the bottom of the column's content

              // Insert the feature fetcher button here
              // This button will fetch features from the Registry when clicked
              FeatureFetcherButton(dataInterfaceController: dataInterfaceController),
              const SizedBox(height: 20),

              // Add a link to navigate to the page-based feature fetcher
              // This will push a new route (FeatureFetcherPage) which is a separate screen (Scaffold)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FeatureFetcherPage(dataInterfaceController: dataInterfaceController)),
                  );
                },
                child: Text("View Features Page"),
              ),
              const SizedBox(height: 50),
              //additional spacing at the bottom
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        //adds a fixed footer element at the bottom of the screen
        padding: const EdgeInsets.all(8.0),
        // padding around a Text widget that shows a copyright notice
        child: Text(
          '© 2024 hypermusic.ai All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
