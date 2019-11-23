import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference helperCollection = Firestore.instance.collection('tasks');

class TaskService {

  static final TaskService _instance = new TaskService.internal();

  factory TaskService() => _instance;

  TaskService.internal();

  Stream<QuerySnapshot> getTaskList({String id, int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = helperCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }
}