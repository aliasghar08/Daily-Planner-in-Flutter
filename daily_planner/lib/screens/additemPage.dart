import 'package:daily_planner/utils/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_planner/utils/catalog.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isCompleted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
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

  String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    final now = DateTime.now();

    if (title.isEmpty) {
      FocusScope.of(context).unfocus(); // Dismiss keyboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title cannot be empty.")),
      );
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final newTaskRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc();

      final newTask = Task(
        docId: newTaskRef.id,
        id: now.millisecondsSinceEpoch,
        title: title,
        detail: _detailController.text.trim(),
        date: _selectedDate,
        isCompleted: _isCompleted,
      );

      await newTaskRef.set(newTask.toMap());

      final notificationTime = newTask.date.subtract(const Duration(minutes: 15));
      if (notificationTime.isAfter(now)) {
        try {
          await NotificationService.scheduleNotification(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: 'Upcoming Task',
            body: '${newTask.title} is due at ${DateFormat.jm().format(newTask.date)}',
            scheduledTime: notificationTime,
          );
        } catch (notificationError) {
          print("⚠️ Notification scheduling failed: $notificationError");
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e, stack) {
      print("❌ Error adding task: $e");
      print("Stack trace:\n$stack");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add task.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = formatDate(_selectedDate);
    final timeStr = formatTime(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _detailController,
              decoration: const InputDecoration(labelText: "Detail"),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
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
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Task"),
                    onPressed: _addTask,
                  ),
          ],
        ),
      ),
    );
  }
}
