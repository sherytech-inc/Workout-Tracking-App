import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_card.dart';
import 'create_workout_screen.dart';
import '../app_router.dart';
import '../models/cue.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  Future<void> _openCreateWorkout(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
    );

    // CreateWorkoutScreen returns a Map { id, name, cues }
    if (result is Map<String, dynamic>) {
      final name = (result['name'] as String?)?.trim();
      final cues = (result['cues'] as List<Cue>?) ?? [];

      if (name != null && name.isNotEmpty) {
        await context.read<WorkoutProvider>().addWorkout(name, cues: cues);

        // Optional: force reload from Firestore if needed
        // await context.read<WorkoutProvider>().loadWorkouts();
      }
    }
  }

  void _deleteWithUndo(BuildContext context, int index, String name) async {
    final provider = context.read<WorkoutProvider>();

    // remove from Firestore + local state
    await provider.deleteWorkout(index);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'$name' deleted"),
        duration: const Duration(seconds: 6),
        backgroundColor: const Color(0xFF323232),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.amberAccent,
          onPressed: () async {
            await provider.addWorkout(name, cues: []);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>().workouts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
          ),
        ],
      ),
      body: workouts.isEmpty
          ? const Center(child: Text("No workouts yet"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.8,
              ),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final isRestart = index == 0;
                final workout = workouts[index]; // 👈 Workout model

                return WorkoutCard(
                  title: workout.name,
                  statusText: isRestart ? 'Restart' : "Let's Start",
                  statusType: isRestart ? StatusType.restart : StatusType.start,
                  durationText: '${workout.duration}m 0s',
                  levelText: workout.level.toString(),
                  iconData: Icons.pedal_bike,
                  onNameUpdated: (newName) {
                    context.read<WorkoutProvider>().renameWorkout(
                      index,
                      newName,
                    );
                  },
                  onDeleteRequested: () {
                    _deleteWithUndo(context, index, workout.name);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _openCreateWorkout(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            const SizedBox(width: 48),
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
