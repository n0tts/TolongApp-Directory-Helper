import 'dart:async';

import 'package:TolongApp/bloc_provider.dart';
import 'package:TolongApp/models/task.dart';
import 'package:TolongApp/repositories/tasks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskBloc extends BlocBase {
  TaskBloc();

  final _taskController = StreamController<QuerySnapshot>.broadcast();
  Stream<QuerySnapshot> get getTasks => _taskController.stream;
  Sink<QuerySnapshot> get _setTasks => _taskController.sink;

  void getTasksById(String uid) {
    tasks.getTaskList(uid).listen((tasks) {
      _setTasks.add(tasks);
    });
  }

  Future<DocumentReference> addTask(Task task) async {
    var reference = await tasks.addTask(task);
    return reference;
  }

  Future<bool> updateTask(DocumentSnapshot snapshot, Task task) async {
    bool updated = false;
    updated = await tasks.updateTask(snapshot, task);

    return updated;
  }

  @override
  void dispose() {
    _taskController.close();
  }
}
