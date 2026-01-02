import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/home_page.dart';
import 'pages/calendar_page.dart';
import 'services/holiday_service.dart';

void main() {
  initializeDateFormatting().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  final HolidayService? holidayService;

  const MyApp({super.key, this.holidayService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vai ter fogos hoje?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFFFF9F0), // Creamy white
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D6E63), // Warm Cocoa
          primary: const Color(0xFF8D6E63), // Warm Cocoa
          secondary: const Color(0xFFA1887F), // Lighter Cocoa
          surface: const Color(0xFFFFFFFF),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xFF4E342E),
          ), // Dark Brown Text
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xFF795548),
          ), // Medium Brown Text
        ),
      ),
      home: MainScreen(holidayService: holidayService),
    );
  }
}

class MainScreen extends StatefulWidget {
  final HolidayService? holidayService;

  const MainScreen({super.key, this.holidayService});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final HolidayService _holidayService;

  @override
  void initState() {
    super.initState();
    _holidayService = widget.holidayService ?? HolidayService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(holidayService: _holidayService),
          CalendarPage(holidayService: _holidayService),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Hoje'),
                _buildNavItem(1, Icons.calendar_month_rounded, 'Calendário'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFD7CCC8)
                  : Colors.transparent, // Lighter Cocoa
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? const Color(0xFF5D4037)
                      : Colors.grey[400], // Darker Cocoa
              size: 28,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF5D4037),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
