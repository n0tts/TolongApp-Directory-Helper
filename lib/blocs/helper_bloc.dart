import 'dart:async';

import 'package:TolongApp/bloc_provider.dart';
import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/services/preferences.dart';
import 'package:TolongApp/repositories/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelperBloc extends BlocBase {
  HelperBloc();

  final _workerController = StreamController<DocumentSnapshot>.broadcast();
  Stream<DocumentSnapshot> get getWorker => _workerController.stream;
  Sink<DocumentSnapshot> get _setWorker => _workerController.sink;

  Future<DocumentSnapshot> getHelperById(String uid) async {
    DocumentSnapshot snapshot = await helper.getHelper(uid);
    return snapshot;
  }

  Future<void> addHelper(Worker data) async {
    String uid = await helper.addHelper(data);
    await preferences.setHelperId(uid);
  }

  Future<bool> updateHelper(DocumentSnapshot snapshot, Worker data) async {
    bool updated = await helper.updateHelper(snapshot, data);
    return updated;
  }

  void deleteHelper(DocumentSnapshot snapshot) {
    helper.deleteHelper(snapshot);
  }

  void getHelperWithId(String uid) {
    helper.getHelperWithId(uid).listen((data) {
      _setWorker.add(data);
    });
  }

  Future<String> getHelperWithEmail(String email) async {
    String uid = await helper.getHelperWithEmail(email);
    await preferences.setHelperId(uid);
    return uid;
  }

  @override
  void dispose() {
    _workerController.close();
  }
}
