import 'package:TolongApp/models/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleRepository {
  final CollectionReference collection =
      Firestore.instance.collection('schedules');

  Stream<QuerySnapshot> getAll() {
    return collection.snapshots();
  }

  Stream<QuerySnapshot> getLast3DaysSchedule(String uid) {
    return collection.where('reference', isEqualTo: uid).snapshots();
  }

  Future<String> addSchedule(Schedule schedule) async {
    DocumentReference reference = await collection.add(schedule.toMap());
    print('Successfully created new schedule : ' + reference.documentID);
    return reference.documentID;
  }

  Future<DocumentSnapshot> getSchedule(String uid) async {
    DocumentSnapshot snapshot = await collection.document(uid).get();
    print('Successfully fetch a schedule : ' + snapshot.documentID);
    return snapshot;
  }

  Future<bool> updateSchedule(
      DocumentSnapshot snapshot, Schedule schedule) async {
    bool updated = false;
    await collection
        .document(snapshot.documentID)
        .updateData(schedule.toMap())
        .then((success) {
      updated = true;
    }).catchError((error) {
      print(error);
    });

    return updated;
  }

  Future<List<DocumentSnapshot>> getSchedulesByDateRange(
      String uid, DateTime now, DateTime dayAfterTomorrow) async {
    List<DocumentSnapshot> list = [];
    await collection
        .where('dates', isGreaterThanOrEqualTo: now)
        .where('dates', isLessThanOrEqualTo: dayAfterTomorrow)
        .getDocuments()
        .then((snapshot) {
      list = snapshot.documents;
    });

    list.removeWhere((item) => item.data['reference'] != uid);

    return list;
  }

  void deleteSchedule(DocumentSnapshot snapshot) async {
    await collection.document(snapshot.documentID).delete().then((complete) {
      print('Successfully remove schedule : ' + snapshot.documentID);
    }).catchError((error) {
      print('Failed to remove schedule : ' + error.toString());
    });
  }
}

ScheduleRepository schedules = ScheduleRepository();
