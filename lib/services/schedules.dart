import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference helperCollection = Firestore.instance.collection('schedules');

class ScheduleService {

  static final ScheduleService _instance = new ScheduleService.internal();

  factory ScheduleService() => _instance;

  ScheduleService.internal();

  Stream<QuerySnapshot> getScheduleList({String id, int offset, int limit}) {
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