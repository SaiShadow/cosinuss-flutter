import 'package:cosinuss/models/task.dart';
import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  const TaskItem(
      {Key? key,
      required this.task,
      required this.onTaskCompletionChange,
      required this.onDismissed})
      : super(key: key);

  final Task task;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.name,
                style: Theme.of(context).textTheme.bodyLarge,
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
