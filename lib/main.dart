import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/meta_mask_provider.dart';

// Models

// Views
import 'package:hypermusic/view/pages/home_page.dart';
import 'package:hypermusic/view/pages/edit_page.dart';
import 'package:hypermusic/view/pages/explore_page.dart';
import 'package:hypermusic/view/pages/trade_page.dart';
import 'package:hypermusic/view/pages/profile_page.dart';

//Controllers
import 'package:hypermusic/controller/data_interface_controller.dart';
import 'package:hypermusic/controller/registry_controller.dart';

import 'registry_initializer.dart';

void fetchFeatures(DataInterfaceController registry) async {
  final features = await registry.getAllFeatureNames();
  print("Features: $features");
  print("Test Build Web");
}

void main() {

  final DataInterfaceController registry = RegistryController();

  // Initialize the registry with default features and transformations
  RegistryInitializer.initialize(registry);
  fetchFeatures(registry);

  runApp(
    MultiProvider(
      providers: [
        Provider<DataInterfaceController>.value(value: registry),
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
        '/': (context) => HomePage(dataInterfaceController: Provider.of<DataInterfaceController>(context, listen: false)),
        '/edit': (context) => EditPage(dataInterfaceController: Provider.of<DataInterfaceController>(context, listen: false),),
        '/explore': (context) => ExplorePage(),
        '/trade': (context) => TradePage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
