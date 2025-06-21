import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:daily_planner/utils/notification.dart';
import 'package:flutter/material.dart';
import 'package:daily_planner/utils/catalog.dart';
import 'package:intl/intl.dart';

class ItemDetailPage extends StatelessWidget {
  final Task task;

  const ItemDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(task.date);
    final formattedTime = TimeOfDay.fromDateTime(task.date).format(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Task Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(task.detail, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text("Date: $formattedDate", style: const TextStyle(fontSize: 16)),
            Text("Time: $formattedTime", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(task.isCompleted ? "Completed" : "Pending"),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                final randomId = DateTime.now().millisecondsSinceEpoch
                    .remainder(100000);
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: randomId, // 👈 Unique ID each time
                    channelKey: 'basic_channel',
                    title: '🔔 Test Notification',
                    body: 'You tapped the test button!',
                    notificationLayout: NotificationLayout.Default,
                  ),
                );
              },
              child: Text("Test Notification"),
            ),
          ],
        ),
      ),
    );
  }
}
