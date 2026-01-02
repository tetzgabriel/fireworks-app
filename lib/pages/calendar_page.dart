import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../fireworks_events.dart';
import '../services/holiday_service.dart';

class CalendarPage extends StatefulWidget {
  final HolidayService holidayService;

  const CalendarPage({super.key, required this.holidayService});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<FireworksEvent>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  Map<DateTime, List<FireworksEvent>> _events = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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

      final holidaysCurrentYear = await widget.holidayService.fetchHolidays(currentYear);
      final holidaysNextYear = await widget.holidayService.fetchHolidays(nextYear);

      final allEvents = <DateTime, List<FireworksEvent>>{};
      
      void merge(Map<DateTime, List<FireworksEvent>> source) {
        source.forEach((date, events) {
          if (allEvents.containsKey(date)) {
            allEvents[date]!.addAll(events);
          } else {
            allEvents[date] = List.from(events);
          }
        });
      }

      merge(holidaysCurrentYear);
      merge(holidaysNextYear);

      if (mounted) {
        setState(() {
          _events = allEvents;
          _isLoading = false;
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao carregar eventos.';
        });
      }
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
              backgroundColor: const Color(0xFF2C2C2C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Criar Lembrete', style: TextStyle(color: Colors.amber)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text("Horário", style: TextStyle(color: Colors.white)),
                      trailing: Text(
                        selectedTime.format(context), 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)
                      ),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
      backgroundColor: Colors.transparent, // Background handled by parent
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, color: Colors.white38, size: 64),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: _fetchEvents,
                          child: const Text('Tentar novamente', style: TextStyle(color: Colors.amber)),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: _buildCalendar(),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _buildEventList(),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Darker cozy blue-grey
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
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
          defaultTextStyle: const TextStyle(color: Colors.white),
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
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white70),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white70),
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
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum evento neste dia',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: value.length,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Bottom padding for FAB if needed
          itemBuilder: (context, index) {
            final event = value[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF252535),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.celebration_rounded, color: event.color),
                ),
                title: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: event.description.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          event.description,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, color: Colors.amber),
                  tooltip: 'Adicionar à agenda',
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
