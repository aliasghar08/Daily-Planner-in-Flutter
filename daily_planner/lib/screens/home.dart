import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_planner/screens/additemPage.dart';
import 'package:daily_planner/utils/catalog.dart';
import 'package:daily_planner/utils/drawer.dart';
import 'package:daily_planner/utils/item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum TaskFilter { all, completed, incomplete, overdue }

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<Task> tasks = [];
  bool isLoading = true;
  bool isAuthResolved = false;
  User? user;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) {
      setState(() {
        user = newUser;
        isAuthResolved = true;
      });

      if (newUser != null) {
        fetchTasksFromFirestore(newUser);
      } else {
        setState(() {
          tasks = [];
          isLoading = false;
        });
      }
    });
  }

  Future<void> fetchTasksFromFirestore(User user) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .orderBy('date')
          .get();

      final List<Task> loadedTasks = snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), docId: doc.id))
          .toList();

      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
    } catch (e) {
      print("Error while fetching tasks: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  List<Task> getFilteredTasks(TaskFilter filter) {
  final now = DateTime.now();
  DateTime? combinedDateTime;
  if (selectedDate != null) {
    combinedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime?.hour ?? 0,
      selectedTime?.minute ?? 0,
    );
  }

  return tasks.where((task) {
    final taskDate = task.date is Timestamp
        ? (task.date as Timestamp).toDate()
        : task.date is DateTime
            ? task.date
            : DateTime.tryParse(task.date.toString()) ?? DateTime.now();

    bool matchesFilter = switch (filter) {
      TaskFilter.completed => task.isCompleted == true,
      TaskFilter.incomplete => task.isCompleted == false && !taskDate.isBefore(now),
      TaskFilter.overdue => task.isCompleted == false && taskDate.isBefore(now),
      TaskFilter.all => true,
    };

    bool matchesDate = true;
    if (combinedDateTime != null) {
      matchesDate = taskDate.year == combinedDateTime.year &&
          taskDate.month == combinedDateTime.month &&
          taskDate.day == combinedDateTime.day &&
          taskDate.hour == combinedDateTime.hour &&
          taskDate.minute == combinedDateTime.minute;
    }

    return matchesFilter && matchesDate;
  }).toList();
}


  Widget buildTaskList(TaskFilter filter) {
    final filteredTasks = getFilteredTasks(filter);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredTasks.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No tasks found"),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: ElevatedButton.icon(
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskPage()),
                );
                if (added == true) {
                  fetchTasksFromFirestore(user!);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length + 1,
      itemBuilder: (context, index) {
        if (index < filteredTasks.length) {
          return ItemWidget(
            item: filteredTasks[index],
            onEditDone: () => fetchTasksFromFirestore(user!),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskPage()),
                );
                if (added == true) {
                  fetchTasksFromFirestore(user!);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Tasks"),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Completed"),
              Tab(text: "Incomplete"),
              Tab(text: "Overdue"),
            ],
          ),
        ),
        drawer: MyDrawer(user: user),
        body: !isAuthResolved
            ? const Center(child: CircularProgressIndicator())
            : user == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("🔒 Please login to view your tasks"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                     // buildDateTimeFilter(),
                      Expanded(
                        child: TabBarView(
                          children: [
                            buildTaskList(TaskFilter.all),
                            buildTaskList(TaskFilter.completed),
                            buildTaskList(TaskFilter.incomplete),
                            buildTaskList(TaskFilter.overdue),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
