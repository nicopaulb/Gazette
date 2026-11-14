import 'package:flutter/material.dart';
import 'package:gazette/screens/fragments/AddPostFragment.dart';
import 'package:gazette/screens/fragments/CalendarFragment.dart';
import 'package:gazette/screens/fragments/HomeFragment.dart';
import 'package:gazette/screens/fragments/NewspaperFragment.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Common.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  // Create tabs on first visit and retain their form and scroll state.
  final List<Widget?> _tabs = [null, null, null, null];

  @override
  Widget build(BuildContext context) {
    _tabs[selectedIndex] ??= switch (selectedIndex) {
      0 => HomeFragment(),
      1 => AddPostFragment(),
      2 => NewspaperFragment(),
      _ => CalendarFragment(),
    };
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      body: IndexedStack(
        index: selectedIndex,
        children: _tabs.map((tab) => tab ?? const SizedBox.shrink()).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColorPrimary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Publier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper),
            label: 'Gazettes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Calendrier',
          ),
        ],
      ),
    );
  }
}
