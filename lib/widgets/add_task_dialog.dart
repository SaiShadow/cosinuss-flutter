import 'package:cosinuss/models/task.dart';
import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({Key? key, required this.onAddTaskPressed})
      : super(key: key);

  final void Function(Task) onAddTaskPressed;

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Automatically set the focus to the text field when this dialog is opened.
    // This will also open the device keyboard.
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new task'),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: const InputDecoration(
          hintText: 'What task are you working on?',
        ),
        // onSubmitted is called when the enter or confirm key on the keyboard
        // is pressed.
        onSubmitted: (_) => _onAddTaskPressed(),
      ),
      actions: [
        TextButton(
          onPressed: _onAddTaskPressed,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _onAddTaskPressed() {
    final taskName = _controller.text;
    // Use the current timestamp as a unique ID.
    final id = DateTime.now().millisecondsSinceEpoch;
    final newItem = Task(id: id, name: taskName);

    widget.onAddTaskPressed(newItem);
    // Close the dialog.
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
