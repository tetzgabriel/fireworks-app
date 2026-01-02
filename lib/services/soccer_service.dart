import 'package:flutter/material.dart';
import '../fireworks_events.dart';

class SoccerService {
  // Hardcoded list of classic match-ups for realistic simulation
  final List<Map<String, String>> _classicos = [
    {
      'title': 'Clássico: Fla-Flu',
      'desc': 'Flamengo vs Fluminense (RJ). O charme do Maracanã em jogo decisivo.',
      'state': 'Rio de Janeiro'
    },
    {
      'title': 'Derby Paulista',
      'desc': 'Corinthians vs Palmeiras (SP). Rivalidade histórica em São Paulo.',
      'state': 'São Paulo'
    },
    {
      'title': 'Grenal',
      'desc': 'Grêmio vs Internacional (RS). A maior rivalidade do sul do país.',
      'state': 'Rio Grande do Sul'
    },
    {
      'title': 'Clássico dos Milhões',
      'desc': 'Flamengo vs Vasco (RJ). Duelo de gigantes no Rio de Janeiro.',
      'state': 'Rio de Janeiro'
    },
    {
      'title': 'Majestoso',
      'desc': 'São Paulo vs Corinthians (SP). Morumbi ou Neo Química Arena lotados.',
      'state': 'São Paulo'
    },
    {
      'title': 'Clássico Mineiro',
      'desc': 'Atlético-MG vs Cruzeiro (MG). Belo Horizonte para para assistir.',
      'state': 'Minas Gerais'
    },
    {
      'title': 'San-São',
      'desc': 'Santos vs São Paulo (SP). Jogo técnico e de muita tradição.',
      'state': 'São Paulo'
    },
    {
      'title': 'Clássico Vovô',
      'desc': 'Botafogo vs Fluminense (RJ). O clássico mais antigo do Brasil.',
      'state': 'Rio de Janeiro'
    },
  ];

  Future<Map<DateTime, List<FireworksEvent>>> fetchSoccerEvents(int year) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulating network

    final Map<DateTime, List<FireworksEvent>> events = {};

    // 1. Campeonatos Estaduais (Mid-Jan to Mid-April)
    final startEstaduais = DateTime.utc(year, 1, 15);
    final endEstaduais = DateTime.utc(year, 4, 15);
    _generateSeasonEvents(
      events,
      startEstaduais,
      endEstaduais,
      isStateChampionship: true,
    );

    // 2. Brasileirão (Mid-April to Early Dec)
    final startBrasileirao = DateTime.utc(year, 4, 16);
    final endBrasileirao = DateTime.utc(year, 12, 5);
    _generateSeasonEvents(
      events,
      startBrasileirao,
      endBrasileirao,
      isStateChampionship: false,
    );

    // 3. Jogos do Brasil (World Cup / FIFA Dates)
    _generateBrazilGames(events, year);

    return events;
  }

  void _generateSeasonEvents(
    Map<DateTime, List<FireworksEvent>> events,
    DateTime start,
    DateTime end, {
    required bool isStateChampionship,
  }) {
    var date = start;
    int weekCounter = 0;

    while (date.isBefore(end)) {
      // Logic:
      // - Sundays (7): High probability of a "Classic" match.
      // - Wednesdays (3): Regular round.
      
      if (date.weekday == DateTime.sunday) {
        // Pick a classic based on the week number to rotate through them
        final classic = _classicos[weekCounter % _classicos.length];
        
        String title = isStateChampionship 
            ? 'Estadual: ${classic['title']}' 
            : 'Brasileirão: ${classic['title']}';
            
        String description = '${classic['desc']}\n'
            'Estado: ${classic['state']}\n'
            'Alta probabilidade de queima de fogos após o jogo.';

        _addEvent(events, date, title, Colors.green, description: description);
        weekCounter++;
      } else if (date.weekday == DateTime.wednesday) {
        // Wednesday games are usually generic rounds
        String title = isStateChampionship 
            ? 'Estaduais: Rodada de Quarta' 
            : 'Brasileirão: Rodada de Quarta';
            
        String description = 'Jogos decisivos acontecendo simultaneamente em SP, RJ, MG e RS.\n' 
            'Fique atento a fogos isolados durante a noite.';
            
        _addEvent(events, date, title, Colors.green.shade700, description: description);
      }
      
      date = date.add(const Duration(days: 1));
    }
  }

  void _generateBrazilGames(Map<DateTime, List<FireworksEvent>> events, int year) {
    if (year == 2026) {
       _addEvent(
         events, 
         DateTime.utc(year, 6, 11), 
         'Copa do Mundo: Abertura', 
         Colors.yellow,
         description: 'Abertura da Copa do Mundo 2026! O mundo inteiro está assistindo.'
       );
       _addEvent(
         events, 
         DateTime.utc(year, 6, 16), 
         'Brasil x Fase de Grupos', 
         Colors.yellow,
         description: 'Primeiro jogo do Brasil na Copa! Feriado nacional não oficial. Muita festa e fogos.'
       );
       _addEvent(
         events, 
         DateTime.utc(year, 6, 20), 
         'Brasil x Fase de Grupos', 
         Colors.yellow,
         description: 'Segundo jogo da fase de grupos. O país para para torcer.'
       );
       _addEvent(
         events, 
         DateTime.utc(year, 7, 19), 
         'Copa do Mundo: Final', 
         Colors.yellow,
         description: 'Grande Final da Copa do Mundo 2026. Se o Brasil estiver, será histórico!'
       );
    } else {
       // Generic FIFA Dates with opponents
       _addEvent(
         events, 
         DateTime.utc(year, 3, 20), 
         'Amistoso: Brasil x Espanha', 
         Colors.yellow,
         description: 'Amistoso internacional preparatório. Jogo contra seleção europeia forte.'
       );
       _addEvent(
         events, 
         DateTime.utc(year, 9, 5), 
         'Eliminatórias: Brasil x Argentina', 
         Colors.yellow,
         description: 'O maior clássico das Américas! Brasil enfrenta a Argentina. Haja coração e fogos!'
       );
    }
  }

  void _addEvent(
    Map<DateTime, List<FireworksEvent>> events,
    DateTime date,
    String title,
    Color color, {
    String description = '',
  }) {
    final event = FireworksEvent(
      title: title,
      description: description,
      color: color,
    );

    if (events.containsKey(date)) {
      events[date]!.add(event);
    } else {
      events[date] = [event];
    }
  }
}