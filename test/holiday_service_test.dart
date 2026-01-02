import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:vai_ter_fogos_hoje/services/holiday_service.dart';
import 'package:vai_ter_fogos_hoje/fireworks_events.dart';
import 'package:flutter/material.dart';

import 'holiday_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late HolidayService service;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    service = HolidayService(client: mockClient);
  });

  group('HolidayService', () {
    test('fetchHolidays returns a map of FireworksEvent when the call is successful', () async {
      final responseBody = '''
      [
        {
          "date": "2026-01-01",
          "name": "Ano Novo",
          "type": "national"
        },
        {
          "date": "2026-12-25",
          "name": "Natal",
          "type": "national"
        }
      ]
      ''';

      when(mockClient.get(Uri.parse('https://brasilapi.com.br/api/feriados/v1/2026')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      final events = await service.fetchHolidays(2026);

      expect(events, isA<Map<DateTime, List<FireworksEvent>>>());
      expect(events.length, 2);
      
      final date1 = DateTime.utc(2026, 1, 1);
      expect(events.containsKey(date1), true);
      expect(events[date1]!.first.title, 'Ano Novo');
      expect(events[date1]!.first.color, Colors.green); // National = Green
    });

    test('fetchHolidays throws an exception when the call fails', () async {
      when(mockClient.get(Uri.parse('https://brasilapi.com.br/api/feriados/v1/2026')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(service.fetchHolidays(2026), throwsException);
    });
  });
}
