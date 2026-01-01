import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'fireworks_events.dart';

void main() {
  initializeDateFormatting().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vai ter fogos hoje?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.orangeAccent,
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const FireworksCalendarPage(),
    );
  }
}

class FireworksCalendarPage extends StatefulWidget {
  const FireworksCalendarPage({super.key});

  @override
  State<FireworksCalendarPage> createState() => _FireworksCalendarPageState();
}

class _FireworksCalendarPageState extends State<FireworksCalendarPage> {
  late final ValueNotifier<List<FireworksEvent>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<FireworksEvent> _getEventsForDay(DateTime day) {
    // Normalize date to UTC to match our key definition if necessary,
    // or just ensure keys in kEvents are compatible.
    // kEvents keys are UTC 00:00:00.
    // TableCalendar usually returns local or UTC depending on input.
    // Let's normalize just the date part (year, month, day).
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return kEvents[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vai ter fogos hoje?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
        ),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<FireworksEvent>(
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Mês',
          CalendarFormat.twoWeeks: '2 Semanas',
          CalendarFormat.week: 'Semana',
        },
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: Colors.orangeAccent),
          holidayTextStyle: const TextStyle(color: Colors.redAccent),
          selectedDecoration: const BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        locale: 'pt_BR',
      ),
    );
  }

  Widget _buildEventList() {
    return ValueListenableBuilder<List<FireworksEvent>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        if (value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.nightlight_round,
                  size: 64,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sem previsão de fogos para este dia.',
                  style: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: value.length,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemBuilder: (context, index) {
            final event = value[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: event.color.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(12.0),
                gradient: LinearGradient(
                  colors: [
                    event.color.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                leading: Icon(Icons.celebration, color: event.color),
                title: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: event.description.isNotEmpty
                    ? Text(event.description)
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}