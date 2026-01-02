import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'fireworks_events.dart';
import 'services/holiday_service.dart';

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
        dialogTheme: DialogTheme(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const FireworksCalendarPage(),
    );
  }
}

class FireworksCalendarPage extends StatefulWidget {
  final HolidayService? holidayService;

  const FireworksCalendarPage({super.key, this.holidayService});

  @override
  State<FireworksCalendarPage> createState() => _FireworksCalendarPageState();
}

class _FireworksCalendarPageState extends State<FireworksCalendarPage> {
  late final ValueNotifier<List<FireworksEvent>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  late final HolidayService _holidayService;
  Map<DateTime, List<FireworksEvent>> _events = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _holidayService = widget.holidayService ?? HolidayService();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final currentYear = DateTime.now().year;
      final nextYear = currentYear + 1;

      final eventsCurrentYear = await _holidayService.fetchHolidays(currentYear);
      final eventsNextYear = await _holidayService.fetchHolidays(nextYear);

      setState(() {
        _events = {...eventsCurrentYear, ...eventsNextYear};
        _isLoading = false;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar eventos. Verifique sua conexão.';
      });
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<FireworksEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
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

  Future<void> _showCalendarDialog(BuildContext context, FireworksEvent event, DateTime date) async {
    final titleController = TextEditingController(text: "Alerta: ${event.title}");
    final descController = TextEditingController(
      text: "${event.description}\n\nLembrete de segurança: Mantenha pets em local seguro e fechado.",
    );
    TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Criar Lembrete', style: TextStyle(color: Colors.amber)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text("Horário"),
                      trailing: Text(selectedTime.format(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      tileColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final calendarEvent = Event(
                      title: titleController.text,
                      description: descController.text,
                      startDate: DateTime(
                        date.year,
                        date.month,
                        date.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      ),
                      endDate: DateTime(
                        date.year,
                        date.month,
                        date.day,
                        selectedTime.hour + 1,
                        selectedTime.minute,
                      ),
                      allDay: false,
                    );
                    Add2Calendar.addEvent2Cal(calendarEvent);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text('Adicionar', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchEvents,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        child: const Text('Tentar novamente', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildCalendar(),
                    ValueListenableBuilder<List<FireworksEvent>>(
                      valueListenable: _selectedEvents,
                      builder: (context, value, _) {
                        if (value.isNotEmpty) {
                          return _buildPetWarningCard();
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildEventList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPetWarningCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4A1818), // Dark red background
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Risco de Fogos: Atenção aos Pets',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Feriados e comemorações costumam ter queima de fogos. O barulho excessivo causa pânico e ansiedade severa em animais.\n\nMantenha-os em local seguro, fechado e com som ambiente para abafar os ruídos.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
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
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.amber),
                  tooltip: 'Adicionar Lembrete',
                  onPressed: () {
                    _showCalendarDialog(context, event, _selectedDay!);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
