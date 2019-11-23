import 'dart:async';

import 'package:TolongApp/bloc_provider.dart';
import 'package:TolongApp/repositories/earnings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EarningBloc extends BlocBase {
  EarningBloc();

  final _earningsController = StreamController<QuerySnapshot>.broadcast();
  Stream<QuerySnapshot> get getEarnings => _earningsController.stream;
  Sink<QuerySnapshot> get _setEarnings => _earningsController.sink;

  void getHelperEarnings(String uid) {
    earnings.getHelperEarnings(uid).listen((earnings) {
      _setEarnings.add(earnings);
    });
  }

  @override
  void dispose() {
    _earningsController.close();
  }
}
