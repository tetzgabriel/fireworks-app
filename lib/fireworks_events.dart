import 'package:flutter/material.dart';

class FireworksEvent {
  final String title;
  final String description;
  final Color color;

  const FireworksEvent({
    required this.title,
    this.description = '',
    this.color = Colors.red,
  });

  @override
  String toString() => title;
}

final kEvents = <DateTime, List<FireworksEvent>>{
  // New Year's Eve (Reveillon) - High probability everywhere
  DateTime.utc(2025, 12, 31): [
    const FireworksEvent(
      title: 'Réveillon',
      description: 'Queima de fogos em todo o país! Copacabana é o destaque.',
      color: Colors.amber,
    ),
  ],
  DateTime.utc(2026, 1, 1): [
    const FireworksEvent(
      title: 'Ano Novo',
      description: 'Celebrações de Ano Novo continuam em muitos lugares.',
      color: Colors.amber,
    ),
  ],
  // Carnival (varies, usually Feb/March) - 2026: Feb 17
  DateTime.utc(2026, 2, 13): [
    const FireworksEvent(title: 'Início do Carnaval', color: Colors.purple),
  ],
  DateTime.utc(2026, 2, 17): [
    const FireworksEvent(title: 'Terça-feira de Carnaval', color: Colors.purple),
  ],
  // Festas Juninas (June) - especially in Northeast
  DateTime.utc(2026, 6, 23): [
    const FireworksEvent(
      title: 'Véspera de São João',
      description: 'Muitos fogos e fogueiras, especialmente no Nordeste.',
      color: Colors.orange,
    ),
  ],
  DateTime.utc(2026, 6, 24): [
    const FireworksEvent(title: 'Dia de São João', color: Colors.orange),
  ],
  DateTime.utc(2026, 6, 29): [
    const FireworksEvent(title: 'Dia de São Pedro', color: Colors.orange),
  ],
  // Independence Day
  DateTime.utc(2026, 9, 7): [
    const FireworksEvent(title: 'Independência do Brasil', color: Colors.green),
  ],
  // Christmas
  DateTime.utc(2026, 12, 24): [
    const FireworksEvent(title: 'Véspera de Natal', color: Colors.red),
  ],
  DateTime.utc(2026, 12, 25): [
    const FireworksEvent(title: 'Natal', color: Colors.red),
  ],
   DateTime.utc(2026, 12, 31): [
    const FireworksEvent(
      title: 'Réveillon',
      description: 'A grande festa da virada!',
      color: Colors.amber,
    ),
  ],
};

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
