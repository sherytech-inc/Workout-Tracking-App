import 'package:flutter/material.dart';
import 'cue.dart';

class Workout {
  final String id;
  final String name;
  final int duration; // in minutes
  final int level;
  final List<Cue> cues;

  Workout({
    required this.id,
    required this.name,
    required this.duration,
    required this.level,
    this.cues = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration': duration,
      'level': level,
      'cues': cues
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'minutes': c.minutes,
              'seconds': c.seconds,
              'intensity': c.intensity,
              'color': c.color.value,
            },
          )
          .toList(),
    };
  }

  factory Workout.fromMap(String id, Map<String, dynamic> map) {
    final cuesData =
        (map['cues'] as List<dynamic>?)
            ?.map(
              (c) => Cue(
                id: c['id'] as String,
                name: c['name'] as String,
                minutes: (c['minutes'] ?? 0) as int,
                seconds: (c['seconds'] ?? 0) as int,
                intensity: (c['intensity'] ?? 1) as int,
                color: Color((c['color'] ?? Colors.deepPurple.value) as int),
              ),
            )
            .toList() ??
        [];

    return Workout(
      id: id,
      name: (map['name'] ?? '') as String,
      duration: (map['duration'] ?? 0) as int,
      level: (map['level'] ?? 1) as int,
      cues: cuesData,
    );
  }
}
