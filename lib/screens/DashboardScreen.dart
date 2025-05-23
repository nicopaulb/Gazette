import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/screens/fragments/AddPostFragment.dart';
import 'package:gazette/screens/fragments/HomeFragment.dart';
import 'package:gazette/screens/fragments/NewspaperFragment.dart';
import 'package:gazette/screens/fragments/SearchFragment.dart';
import 'package:gazette/utils/Common.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  Widget getFragment() {
    if (selectedIndex == 0) {
      return HomeFragment();
    } else if (selectedIndex == 1) {
      return SearchFragment();
    } else if (selectedIndex == 2) {
      return AddPostFragment();
    } else if (selectedIndex == 3) {
      return NewspaperFragment();
    } else if (selectedIndex == 4) {}
    return SearchFragment();
  }

  @override
  void initState() {
    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      body: getFragment(),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('images/gazette/icons/ic_Home.png',
                    height: 24, width: 24, fit: BoxFit.cover, color: context.iconColor)
                .paddingTop(12),
            label: '',
            activeIcon:
                Image.asset('images/gazette/icons/ic_HomeSelected.png', height: 24, width: 24, fit: BoxFit.cover)
                    .paddingTop(12),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('images/gazette/icons/ic_Search.png',
                    height: 24, width: 24, fit: BoxFit.cover, color: context.iconColor)
                .paddingTop(12),
            label: '',
            activeIcon:
                Image.asset('images/gazette/icons/ic_SearchSelected.png', height: 24, width: 24, fit: BoxFit.cover)
                    .paddingTop(12),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('images/gazette/icons/ic_Plus.png',
                    height: 24, width: 24, fit: BoxFit.cover, color: context.iconColor)
                .paddingTop(12),
            label: '',
            activeIcon:
                Image.asset('images/gazette/icons/ic_PlusSelected.png', height: 24, width: 24, fit: BoxFit.cover)
                    .paddingTop(12),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('images/gazette/icons/ic_Newspaper.png',
                    height: 24, width: 24, fit: BoxFit.cover, color: context.iconColor)
                .paddingTop(12),
            label: '',
            activeIcon:
                Image.asset('images/gazette/icons/ic_NewspaperSelected.png', height: 24, width: 24, fit: BoxFit.cover)
                    .paddingTop(12),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('images/gazette/icons/ic_Calendar.png', height: 24, width: 24, fit: BoxFit.cover)
                .paddingTop(12),
            label: '',
            activeIcon:
                Image.asset('images/gazette/icons/ic_CalendarSelected2.png', height: 24, width: 24, fit: BoxFit.cover)
                    .paddingTop(12),
          ),
        ],
        onTap: (val) {
          selectedIndex = val;
          setState(() {});
        },
        currentIndex: selectedIndex,
      ),
    );
  }
}
