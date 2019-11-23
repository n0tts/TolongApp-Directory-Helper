import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference earningCollection =
    Firestore.instance.collection('earnings');

class EarningService {
  Stream<QuerySnapshot> getEarningByDate(String date, String reference) {
    Stream<QuerySnapshot> snapshots = earningCollection
        .where('date', isEqualTo: date)
        .where('worker', isEqualTo: reference)
        .snapshots();
    return snapshots;
  }
}
