import 'dart:async';

import 'package:TolongApp/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference collection = Firestore.instance.collection('tasks');

class TaskRepository {
  static final TaskRepository _instance = new TaskRepository.internal();

  factory TaskRepository() => _instance;

  TaskRepository.internal();

  Stream<QuerySnapshot> getTaskList(String uid) {
    Stream<QuerySnapshot> snapshots =
        collection.where('worker', isEqualTo: uid).snapshots();
    return snapshots;
  }

  Future<DocumentReference> addTask(Task task) async {
    var reference = await collection.add(task.toMap());
    return reference;
  }

  Future<bool> updateTask(DocumentSnapshot snapshot, Task task) async {
    bool updated = false;
    await Firestore.instance.runTransaction((transaction) {
      return transaction.get(snapshot.reference).then((document) {
        if (document.data['status'] == 'new') {
          print(document.data['status']);
          return transaction
              .update(snapshot.reference, {'status': task.status});
        }
      });
    }).then((data) {
      updated = true;
    }).catchError((error) {
      print(error.message);
    });

    return updated;
  }
}

TaskRepository tasks = new TaskRepository();
