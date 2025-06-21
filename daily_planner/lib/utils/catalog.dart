import 'package:cloud_firestore/cloud_firestore.dart';

class CatlalogModel {
  static List<Task> items = [
    Task(
      id: 1,
      title: "Get the meal",
      detail: "I need to have my dinner done on time",
      date: DateTime.now(),
      isCompleted: true,
    ),
    Task(
      id: 2,
      title: "Get your work done before deadline",
      detail: "I need to get my work done before the deadline at any cost",
      date: DateTime.now(),
      isCompleted: true,
    ),
  ];
}




class Task {
  String? docId;
  int id;
  String title;
  String detail;
  DateTime date;
  bool isCompleted;

  Task({
    this.docId,
    required this.id,
    required this.title,
    required this.detail,
    required this.date,
    required this.isCompleted,
  });

  factory Task.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedDate;

    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Task(
      docId: docId,
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      detail: map['detail'] ?? '',
      date: parsedDate,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'detail': detail,
      'date': Timestamp.fromDate(date),
      'isCompleted': isCompleted,
    };
  }
  
}

