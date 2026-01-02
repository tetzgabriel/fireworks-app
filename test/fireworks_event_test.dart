import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:vai_ter_fogos_hoje/fireworks_events.dart';

void main() {
  group('FireworksEvent', () {
    test('supports value comparisons', () {
      const event1 = FireworksEvent(
        title: 'Event',
        description: 'Desc',
        color: Colors.red,
      );
      
      expect(event1.title, 'Event');
      expect(event1.description, 'Desc');
      expect(event1.color, Colors.red);
    });

    test('toString returns title', () {
      const event = FireworksEvent(title: 'My Event');
      expect(event.toString(), 'My Event');
    });
  });
}
