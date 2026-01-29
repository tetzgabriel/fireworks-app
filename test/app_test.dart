import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vai_ter_fogos_hoje/main.dart';
import 'package:vai_ter_fogos_hoje/services/holiday_service.dart';
import 'package:vai_ter_fogos_hoje/fireworks_events.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app_test.mocks.dart';

@GenerateMocks([HolidayService])
void main() {
  late MockHolidayService mockService;

  setUpAll(() {
    initializeDateFormatting();
  });

  setUp(() {
    mockService = MockHolidayService();
  });

  Widget createWidgetUnderTest() {
    return MyApp(holidayService: mockService);
  }

  testWidgets('HomePage shows "Não" when no fireworks today', (WidgetTester tester) async {
    // Arrange
    when(mockService.fetchHolidays(any)).thenAnswer((_) async => {});

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 1)); // Advance time

    // Assert
    expect(find.text('Não'), findsOneWidget);
    expect(find.text('Provavelmente NÃO teremos comemorações com fogos hoje. 🐶🐱'), findsOneWidget);
  });

  testWidgets('HomePage shows "SIM!" when there are fireworks today', (WidgetTester tester) async {
    // Arrange
    final today = DateTime.now();
    final normalizedToday = DateTime.utc(today.year, today.month, today.day);
    final events = {
      normalizedToday: [
        const FireworksEvent(title: 'Ano Novo', description: 'Feliz Ano Novo!', color: Colors.amber)
      ]
    };

    when(mockService.fetchHolidays(any)).thenAnswer((_) async => events);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 1)); // Advance time

    // Assert
    expect(find.text('SIM!'), findsOneWidget);
    expect(find.text('Cuidado redobrado! Hoje é dia de muitos fogos! 🎆'), findsOneWidget);
    expect(find.text('Ano Novo'), findsOneWidget);
  });

  testWidgets('Can navigate to CalendarPage', (WidgetTester tester) async {
    // Arrange
    when(mockService.fetchHolidays(any)).thenAnswer((_) async => {});

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify we are on Home
    expect(find.text('Hoje'), findsOneWidget);
    
    // Tap on Calendar tab (find by icon since label is hidden when unselected)
    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // Wait for tab switch animation

    // Assert
    expect(find.byType(PageView), findsOneWidget); // TableCalendar uses PageView
  });
}
