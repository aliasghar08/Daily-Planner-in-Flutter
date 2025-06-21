import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_planner/screens/itemdetailedit.dart';
import 'package:daily_planner/screens/itemdetailpage.dart';
import 'package:daily_planner/utils/catalog.dart';
import 'package:daily_planner/utils/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ItemWidget extends StatefulWidget {
  final Task item;
  final VoidCallback? onEditDone;

  const ItemWidget({super.key, required this.item, this.onEditDone});

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  bool? isChecked;

  @override
  Widget build(BuildContext context) {

    Future<void> changeCompleted(bool? newStatus) async {
    setState(() {
      isChecked = newStatus;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Update task status in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(widget.item.docId)
          .update({'isCompleted': newStatus});

      // Manage notifications
      if (newStatus == true) {
        await NotificationService.cancelNotification(widget.item.id);
      } else {
        if (widget.item.date.isAfter(DateTime.now())) {
          await NotificationService.scheduleNotification(
            id: widget.item.id,
            title: widget.item.title,
            body: widget.item.detail,
            scheduledTime: widget.item.date,
          );
        }
      }

      widget.onEditDone!();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update task status")),
      );
    }
  }

    final formattedDate = DateFormat('MMM d, yyyy').format(widget.item.date);
    final formattedTime = TimeOfDay.fromDateTime(
      widget.item.date,
    ).format(context);

    Future<void> deleteTask(Task task) async {
      if (task.docId == null) {
        print("Error: docId is null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid task reference (no docId).")),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not signed in")));
        return;
      }

      try {
        // Try canceling the notification safely
        try {
          await NotificationService.cancelNotification(task.id);
        } catch (e) {
          print("Failed to cancel notification: $e");
        }

        final uid = user.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .doc(task.docId)
            .delete();

        print("Task with docId '${task.docId}' deleted successfully.");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Task deleted")));

        if (widget.onEditDone != null) widget.onEditDone!();
      } catch (e) {
        print("Error deleting task: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to delete task")));
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailPage(task: widget.item),
            ),
          );
        },
        child: ListTile(
          leading: IconButton(
            icon: Icon(
              widget.item.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
            ),
            color: widget.item.isCompleted ? Colors.green : Colors.grey,
            onPressed: () => changeCompleted(!(isChecked ?? false)),

          ),
          title: Text(
            widget.item.title,
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('$formattedDate at $formattedTime'),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'share':
                  final text =
                      "${widget.item.title}\n${widget.item.detail}\n$formattedDate at $formattedTime";
                  Share.share(text);
                  break;
                case 'edit':
                  final shouldReload = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskPage(task: widget.item),
                    ),
                  );
                  if (shouldReload == true && widget.onEditDone != null) {
                    widget.onEditDone!();
                  }
                  break;
                case 'delete':
                  deleteTask(widget.item);
                  break;
                case 'favorite':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Favorited (you can implement logic here)"),
                    ),
                  );
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Share'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'favorite',
                    child: ListTile(
                      leading: Icon(Icons.favorite),
                      title: Text('Favorite'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    ),
                  ),
                ],
          ),
        ),
      ),
    );
  }
}
