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

  String _formatDate() {
    final date = DateFormat("d 'de' MMMM", 'pt_BR').format(DateTime.now());
    return date.split(' ').map((word) {
      if (word.toLowerCase() == 'de') return word;
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
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
                ? [const Color(0xFFBA68C8), const Color(0xFFF06292)] // Purple to Pink (Celebration)
                : [const Color(0xFFE6DECE), const Color(0xFFF9F5F0)], // Warm Beige to Cream (Cozy)
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
                        _formatDate(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: hasFireworks ? Colors.white : const Color(0xFF5D4037),
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
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
                              child: const Icon(Icons.celebration_rounded, size: 120, color: Colors.white),
                            )
                          : const Icon(Icons.weekend_rounded, size: 100, color: Color(0xFF8D6E63)),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Main Text
                      Text(
                        hasFireworks ? 'SIM!' : 'Não',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          color: hasFireworks ? Colors.white : const Color(0xFF4E342E),
                          shadows: [
                            BoxShadow(
                              color: hasFireworks ? Colors.purple.withValues(alpha: 0.3) : Colors.brown.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        hasFireworks 
                          ? 'Vai ter fogos hoje! 🎆' 
                          : 'O dia será tranquilo! 🐶🐱',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          color: hasFireworks ? Colors.white : const Color(0xFF5D4037),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      if (hasFireworks) ...[
                        const SizedBox(height: 48),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: _todayEvents.map((e) => Column(
                              children: [
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                    color: Colors.white,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets, color: Colors.purpleAccent, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Proteja seus bichinhos! 🎧🐕",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
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