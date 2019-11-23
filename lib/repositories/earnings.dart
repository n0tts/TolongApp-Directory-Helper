import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference collection =
    Firestore.instance.collection('earnings');

class EarningRepository {
  Stream<QuerySnapshot> getHelperEarnings(String reference) {
    Stream<QuerySnapshot> snapshots =
        collection.where('helper', isEqualTo: reference).snapshots();
    return snapshots;
  }
}

EarningRepository earnings = new EarningRepository();
