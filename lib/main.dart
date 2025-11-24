import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ingredients_provider.dart';
import 'providers/menu_items_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IngredientsProvider()),
        ChangeNotifierProvider(create: (_) => MenuItemsProvider()),
      ],
      child: MaterialApp(
        title: 'CostTable',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF565E78), // Slate Blue
            secondary: Color(0xFFEA9F87), // Peach
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF565E78),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFEA9F87),
            foregroundColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
