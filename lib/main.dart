import 'package:flutter/material.dart'; //flutter’s Material Design widgets and theme
import 'package:google_fonts/google_fonts.dart'; //custom fonts (in this case, sometypeMono)
import 'package:provider/provider.dart'; //Provider package for state management
import 'providers/meta_mask_provider.dart'; //MetaMaskProvider which handles MetaMask connection logic

import 'pages/home_page.dart'; //HomePage
import 'pages/edit_page.dart'; //EditPage
import 'pages/explore_page.dart'; //ExplorePage
import 'pages/trade_page.dart'; //TradePage
import 'pages/profile_page.dart'; //ProfilePage

import 'mock/mock_api.dart';
import 'interfaces/data_interface.dart';

void main() {
  final DataInterface api = MockAPI(); // Use MockAPI for development

  void fetchFeatures() async {
    final features = await api.getAllFeatures();
    print("Features: $features");
    print("Test Build Web");
  }

  fetchFeatures();

  runApp(
    ChangeNotifierProvider(
      //a part of the Provider package, allows to provide an instance of a ChangeNotifier (in this case, MetaMaskProvider) down the widget tree
      create: (_) => MetaMaskProvider()
        ..start(), //initializes MetaMask-related logic (such as connecting or listening to changes)
      child:
          MyApp(), //MyApp is now a descendant of ChangeNotifierProvider, and anywhere within MyApp, you can access the MetaMaskProvider via Provider.of<MetaMaskProvider>(context).
    ),
  );
}

class MyApp extends StatelessWidget {
  //MyApp extends StatelessWidget (which means it’s a widget that does not hold mutable state of its own). It returns a MaterialApp which is the root widget of this Flutter app.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hypermusic.ai', //app’s title in the app switcher
      debugShowCheckedModeBanner:
          false, //removes the “Debug” banner that appears by default in debug mode at the top right corner
      theme: ThemeData(
        //global theme for the app
        textTheme: GoogleFonts.sometypeMonoTextTheme(
          Theme.of(context).textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Color(0xFF007BFF)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Color(0xFF007BFF)),
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        //With this setup, you can navigate between pages simply by calling: "Navigator.pushNamed(context, '/path');"
        '/': (context) => HomePage(),
        '/edit': (context) => EditPage(),
        '/explore': (context) => ExplorePage(),
        '/trade': (context) => TradePage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
