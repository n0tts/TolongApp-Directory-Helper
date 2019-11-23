import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference helperCollection =
    Firestore.instance.collection('helpers');

class HelperService {
  static final HelperService _instance = new HelperService.internal();

  factory HelperService() => _instance;

  HelperService.internal();

  Stream<QuerySnapshot> getHelperList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = helperCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<QuerySnapshot> getHelperListByAvailability(bool isAvailable, String category) {
    Stream<QuerySnapshot> snapshots = helperCollection
        .reference()
        .where('availability', isEqualTo: isAvailable)
        .where('category', isEqualTo: category)
        .snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot> getHelperListByCategory(String category) {
    Stream<QuerySnapshot> snapshots = helperCollection
        .reference()
        .where('category', isEqualTo: category)
        .snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot> getHelperListByName(String name) {
    Stream<QuerySnapshot> snapshots = helperCollection
        .reference()
        .where('firstName', isGreaterThanOrEqualTo: name)
        .snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot> getHelperListByRating(int rating, String category) {
    Stream<QuerySnapshot> snapshots = helperCollection
        .reference()
        .where('rating', isEqualTo: rating)
        .where('category', isEqualTo: category)
        .snapshots();

    return snapshots;
  }

  // Future<void> getHelperByReference(String reference) async {
  //   QuerySnapshot snapshots = await helperCollection
  //       .reference()
  //       .where('age', isEqualTo: 25)
  //       .getDocuments();
  //   print(snapshots.documents[0].reference.documentID);
  // }
  // Future<void> addSampleData() async {
  //   List<Worker> workers = new List();
  //   workers.add(new Worker(
  //       'Jason',
  //       'Borne',
  //       25,
  //       ['SPM', 'Degree'],
  //       ['Professional Helper'],
  //       ['Waiter', 'Clerk'],
  //       true,
  //       5,
  //       new GeoPoint(5.898154, 116.048646),
  //       'assets/images/profiles/images.jpeg',
  //       '_reference',
  //       'restaurant / cafe',
  //       'Luyang'));
  //   workers.add(new Worker(
  //       'Benedict',
  //       'James',
  //       30,
  //       ['SPM', 'Degree'],
  //       ['Helper'],
  //       ['Waiter', 'Clerk'],
  //       true,
  //       4,
  //       new GeoPoint(5.898154, 116.048646),
  //       'assets/images/profiles/images1.jpeg',
  //       '_reference',
  //       'restaurant / cafe'));
  //   workers.add(new Worker(
  //       'Henna',
  //       'Morningstar',
  //       18,
  //       ['SPM'],
  //       ['Regular Helper'],
  //       ['Clerk'],
  //       true,
  //       1,
  //       new GeoPoint(5.898154, 116.048646),
  //       'assets/images/profiles/images2.jpeg',
  //       '_reference',
  //       'restaurant / cafe'));
  //   workers.add(new Worker(
  //       'Craig',
  //       'Daniel',
  //       33,
  //       ['SPM', 'Diploma', 'Degree', 'Master'],
  //       ['Regular Helper'],
  //       ['Clerk'],
  //       true,
  //       5,
  //       new GeoPoint(5.898154, 116.048646),
  //       'assets/images/profiles/images3.jpeg',
  //       '_reference',
  //       'restaurant / cafe'));
  //   workers.add(new Worker(
  //       'Stallion',
  //       'Daniel',
  //       32,
  //       ['SPM', 'Diploma', 'Degree', 'Master'],
  //       ['Regular Helper'],
  //       ['Clerk'],
  //       true,
  //       2,
  //       new GeoPoint(5.898154, 116.048646),
  //       'assets/images/profiles/images4.jpeg',
  //       '_reference',
  //       'office assistant'));
  //   workers.add(new Worker(
  //       'James',
  //       'Tokyo',
  //       45,
  //       ['SPM', 'Diploma', 'Degree', 'Master'],
  //       ['Regular Helper'],
  //       ['Clerk'],
  //       true,
  //       3,
  //       new GeoPoint(5.898154, 116.048646),
  //       'assets/images/profiles/images5.jpeg',
  //       '_reference',
  //       'office assistant'));
  //   for (var worker in workers) {
  //     await helperCollection.add(worker.toMap());
  //   }
  //   print('complete added helper =  =================================');
  // }
}
