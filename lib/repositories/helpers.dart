import 'package:TolongApp/models/worker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelperRepository {
  final CollectionReference collection =
      Firestore.instance.collection('helpers');

  Stream<QuerySnapshot> getAll() {
    return collection.snapshots();
  }

  Stream<DocumentSnapshot> getHelperWithId(String uid) {
    return collection.document(uid).snapshots();
  }

  Future<String> addHelper(Worker helper) async {
    DocumentReference reference = await collection.add(helper.toMap());
    print('Successfully created new helper : ' + reference.documentID);
    return reference.documentID;
  }

  Future<DocumentSnapshot> getHelper(String uid) async {
    DocumentSnapshot snapshot = await collection.document(uid).get();
    print('Successfully fetch a helper : ' + snapshot.documentID);
    return snapshot;
  }

  Future<bool> updateHelper(DocumentSnapshot snapshot, Worker helper) async {
    bool updated = false;
    await collection
        .document(snapshot.documentID)
        .updateData(helper.toMap())
        .then((success) {
      updated = true;
    }).catchError((error) {
      print(error);
    });

    return updated;
  }

  Stream<QuerySnapshot> getHelperByEmail(String email) {
    return collection.where('email', isEqualTo: email).snapshots();
  }

  Future<String> getHelperWithEmail(String email) async {
    return await collection
        .where('email', isEqualTo: email)
        .getDocuments()
        .then((data) {
      if (data.documents.isNotEmpty) {
        if (data.documents.single.exists) {
          return data.documents.single.documentID;
        }
      }
    });
  }

  void deleteHelper(DocumentSnapshot snapshot) async {
    await collection.document(snapshot.documentID).delete().then((complete) {
      print('Successfully remove helper : ' + snapshot.documentID);
    }).catchError((error) {
      print('Failed to remove helper : ' + error.toString());
    });
  }
}

HelperRepository helper = HelperRepository();
