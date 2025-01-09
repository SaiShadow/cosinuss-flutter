import 'package:flutter/material.dart';
import 'package:cosinuss/models/task.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({
    Key? key,
    required this.task,
    required this.isSelected,
    required this.onTaskCompletionChange,
    required this.onDismissed,
    required this.onGraphPressed, // Callback for graph button
  }) : super(key: key);

  final Task task;
  final bool isSelected; // Indicates if this task is selected
  final void Function(bool isCompleted) onTaskCompletionChange;
  final VoidCallback onDismissed;
  final VoidCallback onGraphPressed; // Callback for graph button press

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        onDismissed();
      },
      background: const ColoredBox(color: Colors.red),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: isSelected ? 2.0 : 0.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            // Checkbox (isCompleted button) on the left
            Checkbox(
              value: task.isCompleted,
              onChanged: (isDone) {
                if (isDone == null) return;

                onTaskCompletionChange(isDone);
              },
            ),
            const SizedBox(width: 8),

            // Task name in the center
            Expanded(
              child: Text(
                task.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 8),

            // Graph button on the right
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: onGraphPressed, // Call the graph button action
              tooltip: 'View Graph',
            ),
          ],
        ),
      ),
    );
  }
}
