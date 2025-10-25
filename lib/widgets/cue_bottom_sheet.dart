import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cue.dart';

Future<List<Cue>?> showCueBottomSheet({
  required BuildContext context,
  List<Cue>? initialCues,
  required Color Function(int index) colorResolver,
}) {
  return showModalBottomSheet<List<Cue>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final uuid = const Uuid();

      List<Cue> localCues = (initialCues != null && initialCues.isNotEmpty)
          ? initialCues.map((c) => c.copyWith()).toList()
          : [
              Cue(
                id: uuid.v4(),
                name: 'Warm Up',
                minutes: 0,
                seconds: 30,
                intensity: 2,
                color: colorResolver(0),
              ),
            ];

      final nameControllers = <TextEditingController>[];
      for (final cue in localCues) {
        nameControllers.add(TextEditingController(text: cue.name));
      }

      // Track which editor is "expanded". -1 = none
      int expandedIndex = -1;

      void addCue(StateSetter setSheetState) {
        final index = localCues.length;
        final newCue = Cue(
          id: uuid.v4(),
          name: 'Cue ${index + 1}',
          minutes: 0,
          seconds: 30,
          intensity: 2,
          color: colorResolver(index),
        );
        localCues.add(newCue);
        nameControllers.add(TextEditingController(text: newCue.name));
        expandedIndex = index; // open the newly added cue editor
        setSheetState(() {});
      }

      void deleteCue(StateSetter setSheetState, String id) {
        final idx = localCues.indexWhere((c) => c.id == id);
        if (idx >= 0) {
          localCues.removeAt(idx);
          nameControllers.removeAt(idx);
          if (expandedIndex == idx) expandedIndex = -1;
          setSheetState(() {});
        }
      }

      Future<void> pickDuration({
        required StateSetter setSheetState,
        required Cue cue,
      }) async {
        int tempMinutes = cue.minutes;
        int tempSeconds = cue.seconds;

        await showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.white,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (dCtx) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(dCtx).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Set Duration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Minutes',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        tempMinutes = (tempMinutes - 1).clamp(
                                          0,
                                          60,
                                        );
                                        (dCtx as Element).markNeedsBuild();
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    Text(
                                      tempMinutes.toString().padLeft(2, '0'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        tempMinutes = (tempMinutes + 1).clamp(
                                          0,
                                          60,
                                        );
                                        (dCtx as Element).markNeedsBuild();
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Seconds',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        tempSeconds = (tempSeconds - 5).clamp(
                                          0,
                                          59,
                                        );
                                        (dCtx as Element).markNeedsBuild();
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    Text(
                                      tempSeconds.toString().padLeft(2, '0'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        tempSeconds = (tempSeconds + 5).clamp(
                                          0,
                                          59,
                                        );
                                        (dCtx as Element).markNeedsBuild();
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setSheetState(() {
                              cue.minutes = tempMinutes;
                              cue.seconds = tempSeconds;
                            });
                            Navigator.pop(dCtx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Set',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create Cue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Minimized summary list (like image 2)
                    if (localCues.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE6E8EE)),
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < localCues.length; i++)
                              Dismissible(
                                key: ValueKey(localCues[i].id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                                onDismissed: (_) =>
                                    deleteCue(setSheetState, localCues[i].id),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        localCues[i].color, // same faint color
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${localCues[i].name} — ${localCues[i].minutes} min • Level ${localCues[i].intensity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          expandedIndex = i; // expand editor
                                          setSheetState(() {});
                                        },
                                        child: const Icon(
                                          Icons.more_vert,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // Editable cue blocks list (expand on icon tap)
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: localCues.length + 1,
                        itemBuilder: (context, index) {
                          if (index == localCues.length) {
                            return InkWell(
                              onTap: () => addCue(setSheetState),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.add, color: Colors.deepPurple),
                                    SizedBox(width: 8),
                                    Text(
                                      '+ Add another cue',
                                      style: TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Show editor only for expandedIndex
                          if (expandedIndex != index) {
                            return const SizedBox.shrink();
                          }

                          final cue = localCues[index];
                          final nameCtrl = nameControllers[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE6E8EE),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header summary like image 1
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${cue.name} — ${cue.minutes} min • Level ${cue.intensity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          expandedIndex = -1; // minimize editor
                                          setSheetState(() {});
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Text(
                                  'Cue name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: nameCtrl,
                                  onChanged: (val) => cue.name = val,
                                  decoration: const InputDecoration(
                                    hintText: 'Warm Up',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE6E8EE),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Compact Set Duration row like "10m : 30s"
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE6E8EE),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Set Duration',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () => pickDuration(
                                          setSheetState: setSheetState,
                                          cue: cue,
                                        ),
                                        child: Text(
                                          '${cue.minutes.toString().padLeft(2, '0')}m : ${cue.seconds.toString().padLeft(2, '0')}s',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Intensity dropdown
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE6E8EE),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.flash_on,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Set intensity',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      DropdownButton<int>(
                                        value: cue.intensity.clamp(1, 10),
                                        underline: const SizedBox.shrink(),
                                        items: List.generate(
                                          10,
                                          (i) => DropdownMenuItem(
                                            value: i + 1,
                                            child: Text('Level ${i + 1}'),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setSheetState(() {
                                              cue.intensity = val;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Save
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(localCues);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
