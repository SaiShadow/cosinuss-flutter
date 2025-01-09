import 'package:cosinuss/models/task.dart';
import 'package:cosinuss/widgets/add_task_dialog.dart';
import 'package:cosinuss/widgets/task_item.dart';
import 'package:flutter/material.dart';

/// Has the list of tasks and floating action button with the add task dialog.
class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _tasks = <Task>[];
  // Track the selected task
  int? _selectedTaskId;

  @override
  void initState() {
    super.initState();
    _initializeDefaultTask();
  }

  // Add a default task on initialization
  void _initializeDefaultTask() {
    const defaultTask = Task(
      id: 1, // Set a unique ID
      name: 'Quick Start Task',
      isCompleted: false,
      time: '0',
    );

    setState(() {
      _tasks.add(defaultTask);
      _selectedTaskId = defaultTask.id; // Automatically select the default task
    });
  }

  void _addNewTask(Task task) {
    setState(() {
      _tasks.insert(0, task);
      if (_tasks.length == 1) {
        // If this is the only task, make it the selected task
        _selectedTaskId = task.id;
      }
    });
  }

  void _removeTask(int id) {
    setState(() {
      _tasks.removeWhere((element) => element.id == id);

      // Reset selection if the selected task is removed
      if (_selectedTaskId == id) {
        _selectedTaskId = _tasks.isNotEmpty ? _tasks.first.id : null;
      }
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

  void _selectTask(int id) {
    setState(() {
      _selectedTaskId = id; // Set the selected task ID
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70.0), // Space for FAB
        child: _buildList(),
      ),
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
    if (_tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks available. Add a task to get started!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final isSelected = task.id == _selectedTaskId;

        return GestureDetector(
          onTap: () => _selectTask(task.id),
          child: TaskItem(
            task: task,
            isSelected: isSelected,
            onDismissed: () => _removeTask(task.id),
            onTaskCompletionChange: (isCompleted) =>
                _taskCompletionChange(task.id, isCompleted),
            onGraphPressed: () {},
          ),
        );
      },
    );
  }
}
