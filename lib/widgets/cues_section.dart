import 'package:flutter/material.dart';
import '../models/cue.dart';

class CuesSection extends StatelessWidget {
  final List<Cue> cues;
  final VoidCallback onAddCueTap;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(String id) onDelete;

  const CuesSection({
    super.key,
    required this.cues,
    required this.onAddCueTap,
    required this.onReorder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: const Icon(Icons.show_chart, color: Colors.deepPurple),
      title: Text(
        'Cues (${cues.length})',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cues.length,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final cue = cues[index];
            return Dismissible(
              key: ValueKey(cue.id),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.delete, color: Colors.red.shade600),
              ),
              onDismissed: (_) => onDelete(cue.id),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cue.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${cue.name} — ${cue.minutes} min • Level ${cue.intensity}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(Icons.drag_handle, color: Colors.black54),
                  ],
                ),
              ),
            );
          },
        ),
        InkWell(
          onTap: onAddCueTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: const [
                Icon(Icons.add, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  '+ Add Cue',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
