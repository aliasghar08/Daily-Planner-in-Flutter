import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_planner/utils/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daily_planner/utils/catalog.dart';
import 'package:intl/intl.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _detailController;
  late DateTime _selectedDate;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _detailController = TextEditingController(text: widget.task.detail);
    _selectedDate = widget.task.date;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not signed in")),
      );
      return;
    }

    if (widget.task.docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid task reference (missing docId)")),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task title cannot be empty")),
      );
      return;
    }

    try {
      final uid = user.uid;

      final updatedTask = Task(
        docId: widget.task.docId,
        id: widget.task.id,
        title: _titleController.text.trim(),
        detail: _detailController.text.trim(),
        date: _selectedDate,
        isCompleted: _isCompleted,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(updatedTask.docId)
          .update(updatedTask.toMap());

      // Cancel old notification safely
      try {
        await NotificationService.cancelNotification(updatedTask.id);
      } catch (e) {
        print("Notification cancellation failed: $e");
      }

      // Schedule new notification if applicable
      final notificationTime = updatedTask.date.subtract(const Duration(minutes: 15));
      if (!updatedTask.isCompleted && notificationTime.isAfter(DateTime.now())) {
        try {
          await NotificationService.scheduleNotification(
            id: updatedTask.id,
            title: 'Updated Task Reminder',
            body:
                '${updatedTask.title} is due at ${DateFormat.jm().format(updatedTask.date)}',
            scheduledTime: notificationTime,
          );
        } catch (e) {
          print("Notification scheduling failed: $e");
        }
      }

      Navigator.pop(context, true);
    } catch (e) {
      print("Error updating task: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update task")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr = DateFormat('HH:mm').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailController,
              decoration: const InputDecoration(
                labelText: "Detail",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text("Date: $dateStr")),
                Expanded(child: Text("Time: $timeStr")),
                TextButton(
                  onPressed: _pickDateTime,
                  child: const Text("Change"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Completed"),
              value: _isCompleted,
              onChanged: (val) {
                setState(() {
                  _isCompleted = val;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
