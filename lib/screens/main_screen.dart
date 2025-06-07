import 'package:flutter/material.dart';
import 'package:khuta/screens/about/about_screen.dart';
import 'package:khuta/screens/home/home_screen.dart';
import 'package:khuta/screens/settings/settings_screen.dart';
import 'package:khuta/widgets/animated_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SettingsScreen(),
    const AboutScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AnimatedBottomBar(
        activeIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
