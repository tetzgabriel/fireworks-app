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