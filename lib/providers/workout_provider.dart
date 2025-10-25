import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout.dart';
import '../models/cue.dart';

class WorkoutProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Workout> _workouts = [];
  List<Workout> get workouts => List.unmodifiable(_workouts);

  /// Load all workouts for the current user
  Future<void> loadWorkouts() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .orderBy('name')
        .get();

    _workouts = snapshot.docs
        .map((doc) => Workout.fromMap(doc.id, doc.data()))
        .toList();

    notifyListeners();
  }

  /// Add a new workout with optional cues
  Future<void> addWorkout(
    String name, {
    List<Cue> cues = const [],
    int? duration,
    int level = 1,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Compute duration from cues if not provided
    final computedDuration =
        duration ??
        (cues.isEmpty
            ? 30
            : cues
                  .map((c) => c.minutes + (c.seconds / 60.0))
                  .fold<double>(0, (a, b) => a + b)
                  .round());

    final workout = Workout(
      id: '',
      name: name,
      duration: computedDuration,
      level: level,
      cues: cues,
    );

    final docRef = await _db
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .add(workout.toMap());

    final created = Workout(
      id: docRef.id,
      name: workout.name,
      duration: workout.duration,
      level: workout.level,
      cues: workout.cues,
    );

    _workouts.add(created);
    notifyListeners();
  }

  /// Rename a workout
  Future<void> renameWorkout(int index, String newName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final workout = _workouts[index];
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .doc(workout.id)
        .update({'name': newName});

    _workouts[index] = Workout(
      id: workout.id,
      name: newName,
      duration: workout.duration,
      level: workout.level,
      cues: workout.cues,
    );
    notifyListeners();
  }

  /// Delete a workout
  Future<void> deleteWorkout(int index) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final workout = _workouts[index];
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .doc(workout.id)
        .delete();

    _workouts.removeAt(index);
    notifyListeners();
  }
}
