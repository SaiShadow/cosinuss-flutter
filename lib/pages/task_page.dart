import 'package:cosinuss/models/task.dart';
import 'package:cosinuss/widgets/add_task_dialog.dart';
import 'package:cosinuss/widgets/task_item.dart';
import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _tasks = <Task>[];

  void _addNewTask(Task task) {
    setState(() {
      _tasks.insert(0, task);
    });
  }

  void _removeTask(int id) {
    setState(() {
      _tasks.removeWhere((element) => element.id == id);
    });
  }

  // Put the task at the top of the completed/uncompleted list.
  void _taskCompletionChange(int id, bool isCompleted) {
    final int index = _tasks.indexWhere((element) => element.id == id);
    final Task task = _tasks[index];
    final Task newTask = task.copyWith(isCompleted: isCompleted);

    setState(() {
      _tasks.removeAt(index);
      if (isCompleted) {
        // Add completed task to the end of the list.
        _tasks.add(newTask);
      } else {
        // Add uncompleted task to the top of the list.
        _addNewTask(newTask);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTaskDialog(
              onAddTaskPressed: _addNewTask,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return TaskItem(
          task: task,
          onDismissed: () => _removeTask(task.id),
          onTaskCompletionChange: (isCompleted) =>
              _taskCompletionChange(task.id, isCompleted),
        );
      },
    );
  }
}
