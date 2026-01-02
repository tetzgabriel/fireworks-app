import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/holiday_service.dart';
import '../fireworks_events.dart';

class HomePage extends StatefulWidget {
  final HolidayService holidayService;

  const HomePage({super.key, required this.holidayService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<FireworksEvent> _todayEvents = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _checkToday();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkToday() async {
    try {
      final now = DateTime.now();
      
      final eventsMap = await widget.holidayService.fetchHolidays(now.year);
      final normalizedToday = DateTime.utc(now.year, now.month, now.day);
      
      if (mounted) {
        setState(() {
          _todayEvents = eventsMap[normalizedToday] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }

    final hasFireworks = _todayEvents.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: hasFireworks
                ? [const Color(0xFF2E003E), const Color(0xFF000000)] // Purple to Black (Celebration)
                : [const Color(0xFF0F2027), const Color(0xFF203A43)], // Dark Blue (Calm)
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        DateFormat('d "de" MMMM', 'pt_BR').format(DateTime.now()),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const Spacer(),
                      
                      // Icon Animation
                      Center(
                        child: hasFireworks 
                          ? ScaleTransition(
                              scale: Tween(begin: 1.0, end: 1.1).animate(CurvedAnimation(
                                parent: _controller,
                                curve: Curves.easeInOut,
                              )),
                              child: const Icon(Icons.celebration_rounded, size: 120, color: Colors.amber),
                            )
                          : const Icon(Icons.nights_stay_rounded, size: 100, color: Colors.lightBlueAccent),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Main Text
                      Text(
                        hasFireworks ? 'SIM!' : 'Não',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: hasFireworks ? Colors.amber : Colors.white,
                          shadows: [
                            BoxShadow(
                              color: hasFireworks ? Colors.amber.withValues(alpha: 0.5) : Colors.black26,
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        hasFireworks 
                          ? 'Hoje vai ter fogos!' 
                          : 'Hoje a noite será tranquila.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      if (hasFireworks) ...[
                        const SizedBox(height: 48),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: _todayEvents.map((e) => Column(
                              children: [
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (e.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    e.description,
                                    style: const TextStyle(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                ]
                              ],
                            )).toList(),
                          ),
                        ),
                      ],

                      const Spacer(),
                      if (hasFireworks)
                        const Text(
                          "⚠️ Mantenha seus pets seguros!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.redAccent),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}