import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/meta_mask_provider.dart';

import 'pages/home_page.dart';
import 'pages/edit_page.dart';
import 'pages/explore_page.dart';
import 'pages/trade_page.dart';
import 'pages/profile_page.dart';

import 'interfaces/data_interface.dart';
import 'registry/registry.dart';
import 'registry/registry_initializer.dart';

void main() {
  // Initialize the registry with default features and transformations
  final registry = Registry();
  RegistryInitializer.initialize(registry);

  void fetchFeatures() async {
    final features = await registry.getAllFeatures();
    print("Features: $features");
    print("Test Build Web");
  }

  fetchFeatures();

  runApp(
    MultiProvider(
      providers: [
        Provider<DataInterface>.value(value: registry),
        ChangeNotifierProvider(
          create: (_) => MetaMaskProvider()..start(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hypermusic.ai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
        '/': (context) => HomePage(),
        '/edit': (context) => EditPage(
              dataInterface: Provider.of<DataInterface>(context, listen: false),
            ),
        '/explore': (context) => ExplorePage(),
        '/trade': (context) => TradePage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
