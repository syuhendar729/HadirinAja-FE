// File main_page.dart

import 'package:flutter/material.dart';

import 'home_page.dart';
import 'profile_page.dart';
import 'history/history_year_page.dart';

class MainPage extends StatefulWidget {
    const MainPage({super.key});

    @override
    State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    int _selectedIndex = 1;

    final List<Widget> _pages = const [
        HistoryYearPage(),
        HomePage(),
        ProfilePage(),
    ];

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: _pages[_selectedIndex],

            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,

                onTap: (index) {
                    setState(() {
                        _selectedIndex = index;
                    });
                },

                items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.history),
                        label: 'History',
                    ),

                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                    ),

                    BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Profile',
                    ),
                ],
            ),
        );
    }
}