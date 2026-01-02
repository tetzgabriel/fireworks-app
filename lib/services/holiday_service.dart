import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../fireworks_events.dart';

class HolidayService {
  static const String _baseUrl = 'https://brasilapi.com.br/api/feriados/v1';
  final http.Client client;

  HolidayService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<DateTime, List<FireworksEvent>>> fetchHolidays(int year) async {
    final response = await client.get(Uri.parse('$_baseUrl/$year'));

    if (response.statusCode == 200) {
      // Decode with UTF-8 support
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final Map<DateTime, List<FireworksEvent>> events = {};

      for (var item in data) {
        final dateStr = item['date'] as String;
        final dateParts = dateStr.split('-');
        final date = DateTime.utc(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );

        final name = item['name'] as String;
        final description = item['description'] as String? ?? '';
        final type = item['type'] as String? ?? '';

        final event = FireworksEvent(
          title: name,
          description: description,
          color: _getColorForType(type),
        );

        if (events.containsKey(date)) {
          events[date]!.add(event);
        } else {
          events[date] = [event];
        }
      }

      return events;
    } else {
      throw Exception('Failed to load holidays');
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'national':
        return Colors.green;
      case 'state':
        return Colors.blue;
      case 'municipal':
        return Colors.orange;
      default:
        return Colors.amber;
    }
  }
}
