import 'package:cosinuss/models/task.dart';
import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({
    Key? key,
    required this.task,
    required this.isSelected, // New parameter for selection
    required this.onTaskCompletionChange,
    required this.onDismissed,
  }) : super(key: key);

  final Task task;
  final bool isSelected; // Indicates if this task is selected
  final void Function(bool isCompleted) onTaskCompletionChange;
  final VoidCallback onDismissed;

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
          color: isSelected
              ? Colors.blue.withOpacity(0.2)
              : Colors.transparent, // Highlight selection
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: isSelected ? 2.0 : 0.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Checkbox(
              value: task.isCompleted,
              onChanged: (isDone) {
                if (isDone == null) return;

                onTaskCompletionChange(isDone);
              },
            ),
          ],
        ),
      ),
    );
  }
}
