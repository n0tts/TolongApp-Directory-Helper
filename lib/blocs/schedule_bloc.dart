import 'dart:async';

import 'package:TolongApp/bloc_provider.dart';
import 'package:TolongApp/models/schedule.dart';
import 'package:TolongApp/repositories/schedules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleBloc extends BlocBase {
  ScheduleBloc();

  final _schedulesController = StreamController<QuerySnapshot>.broadcast();
  Stream<QuerySnapshot> get getSchedules => _schedulesController.stream;
  Sink<QuerySnapshot> get _setSchedules => _schedulesController.sink;

  void addSchedule(Schedule schedule) async {
    await schedules.addSchedule(schedule);
  }

  Future<bool> updateSchedule(
      DocumentSnapshot snapshot, Schedule schedule) async {
    bool updated = await schedules.updateSchedule(snapshot, schedule);
    return updated;
  }

  Future<List<DocumentSnapshot>> getScheduleByDateRange(
      String uid, DateTime now, DateTime dayAfterTomorrow) async {
    List<DocumentSnapshot> list =
        await schedules.getSchedulesByDateRange(uid, now, dayAfterTomorrow);
    return list;
  }

  void deleteSchedule(DocumentSnapshot snapshot) {
    schedules.deleteSchedule(snapshot);
  }

  void getLatestSchedule(String uid) {
    schedules.getLast3DaysSchedule(uid).listen((data) {
      _setSchedules.add(data);
    });
  }

  @override
  void dispose() {
    _schedulesController.close();
  }
}
