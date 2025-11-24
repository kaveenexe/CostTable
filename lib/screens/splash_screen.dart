import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ingredients_provider.dart';
import '../providers/menu_items_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Simulate minimum splash duration or load essential data
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      Provider.of<IngredientsProvider>(context, listen: false).loadIngredients(),
      Provider.of<MenuItemsProvider>(context, listen: false).loadMenuItems(),
    ]);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA9F87)), // Peach accent
            ),
          ],
        ),
      ),
    );
  }
}
