import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/cue.dart';
import '../widgets/cues_section.dart';
import '../widgets/cue_bottom_sheet.dart';
import '../widgets/workout_graph.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final _uuid = const Uuid();

  List<Cue> _cues = [];

  Color _resolveCueColor(int index) {
    final base = Colors.primaries[index % Colors.primaries.length];
    return base.shade200.withOpacity(0.6);
  }

  Future<void> _openCueSheet() async {
    final result = await showCueBottomSheet(
      context: context,
      initialCues: _cues,
      colorResolver: _resolveCueColor,
    );

    if (result != null) {
      setState(() {
        // Ensure consistent colors based on final order
        for (int i = 0; i < result.length; i++) {
          result[i] = result[i].copyWith(color: _resolveCueColor(i));
        }
        _cues = result;
      });
    }
  }

  void _reorderCues(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _cues.removeAt(oldIndex);
      _cues.insert(newIndex, item);

      for (int i = 0; i < _cues.length; i++) {
        _cues[i] = _cues[i].copyWith(color: _resolveCueColor(i));
      }
    });
  }

  void _deleteCueById(String id) {
    setState(() {
      _cues.removeWhere((c) => c.id == id);

      for (int i = 0; i < _cues.length; i++) {
        _cues[i] = _cues[i].copyWith(color: _resolveCueColor(i));
      }
    });
  }

  Widget _buildOptionRow({
    required IconData leadingIcon,
    required String label,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EE)),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0D47A1),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'id': _uuid.v4(),
        'name': _nameController.text.trim(),
        'cues': _cues,
      });
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Missing Information'),
          content: const Text('Please enter a workout name before saving.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Workout',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text(
                'Workout Name',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFFE6E8EE)),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '⚠ Please enter a workout name';
                  }
                  return null;
                },
              ),

              // Graph appears separately here under the input, only if cues exist
              if (_cues.isNotEmpty) WorkoutGraph(cues: _cues),

              const SizedBox(height: 8),

              // Cues section
              _cues.isEmpty
                  ? _buildOptionRow(
                      leadingIcon: Icons.show_chart,
                      label: 'Create Cues',
                      onAdd: _openCueSheet,
                    )
                  : CuesSection(
                      cues: _cues,
                      onAddCueTap: _openCueSheet,
                      onReorder: _reorderCues,
                      onDelete: _deleteCueById,
                    ),

              _buildOptionRow(
                leadingIcon: Icons.music_note,
                label: 'Add Music',
                onAdd: () {
                  // TODO: implement music picker
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Workout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
