import 'package:flutter/material.dart';

class Cue {
  final String id;
  String name;
  int minutes;
  int seconds;
  int intensity;
  Color color;

  Cue({
    required this.id,
    required this.name,
    this.minutes = 0,
    this.seconds = 30,
    this.intensity = 2,
    required this.color,
  });

  double get totalMinutes => minutes + seconds / 60.0;

  Cue copyWith({
    String? id,
    String? name,
    int? minutes,
    int? seconds,
    int? intensity,
    Color? color,
  }) {
    return Cue(
      id: id ?? this.id,
      name: name ?? this.name,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      intensity: intensity ?? this.intensity,
      color: color ?? this.color,
    );
  }
}
