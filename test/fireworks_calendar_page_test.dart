import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vai_ter_fogos_hoje/main.dart';
import 'package:vai_ter_fogos_hoje/services/holiday_service.dart';
import 'package:vai_ter_fogos_hoje/services/soccer_service.dart';
import 'package:vai_ter_fogos_hoje/fireworks_events.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'fireworks_calendar_page_test.mocks.dart';

@GenerateMocks([HolidayService, SoccerService])
void main() {
  late MockHolidayService mockService;
  late MockSoccerService mockSoccerService;

  setUpAll(() {
    initializeDateFormatting();
  });

  setUp(() {
    mockService = MockHolidayService();
    mockSoccerService = MockSoccerService();
    
    // Default stub for soccer service
    when(mockSoccerService.fetchSoccerEvents(any))
        .thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: FireworksCalendarPage(
        holidayService: mockService,
        soccerService: mockSoccerService,
      ),
    );
  }

  testWidgets('displays loading indicator initially', (WidgetTester tester) async {
    // Arrange: Delay the future to show loading state
    when(mockService.fetchHolidays(any))
        .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return {};
        });

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('displays error message when service fails', (WidgetTester tester) async {
    // Arrange
    when(mockService.fetchHolidays(any)).thenThrow(Exception('Network Error'));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Process future

    // Assert
    expect(find.text('Erro ao carregar eventos. Verifique sua conexão.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('displays calendar and pet warning when events exist', (WidgetTester tester) async {
    // Arrange
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final today = DateTime.now();
    final normalizedToday = DateTime.utc(today.year, today.month, today.day);
    
    final events = {
      normalizedToday: [
        const FireworksEvent(title: 'Event 1', description: 'Desc 1', color: Colors.red)
      ]
    };

    when(mockService.fetchHolidays(any)).thenAnswer((_) async => events);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Vai ter fogos hoje?'), findsOneWidget);
    expect(find.text('Risco de Fogos: Atenção aos Pets'), findsOneWidget);
    expect(find.text('Event 1'), findsAtLeastNWidgets(1));
  });
}
