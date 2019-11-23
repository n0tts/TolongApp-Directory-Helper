import 'dart:math';

import 'package:TolongApp/models/worker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerService {
  Worker autoFillRandomProperties(worker) {
    var age = [21, 22, 23, 24, 25, 30];
    var rating = [1, 2, 3, 4, 5];
    var acedemic = ['SPM', 'DIPLOMA', 'DEGREE', 'BACHELOR', 'PHD', 'MASTER'];
    var category = [
      'restaurant / cafe',
      'office assistant',
      'retail shops',
      'home helper'
    ];
    var position = [
      'Teacher',
      'General Worker',
      'Waiter',
      'Clerk',
      'Librarion',
      'Hairdresser',
      'Electrician'
    ];

    var location = [
      new GeoPoint(5.891842, 116.047966),
      new GeoPoint(5.912854, 116.103679),
      new GeoPoint(6.035551, 116.129481),
      new GeoPoint(5.969974, 116.066506),
      new GeoPoint(5.967585, 116.093405),
      new GeoPoint(5.971096, 116.086528),
      new GeoPoint(5.946788, 116.088010),
      new GeoPoint(5.937181, 116.082317),
      new GeoPoint(5.939963, 116.073706),
      new GeoPoint(5.934463, 116.066517),
    ];

    var random = {
      'firstName': worker.firstName,
      'lastName': worker.lastName,
      'age': getRandom(age, 1),
      'academicQualification': getRandom(acedemic, 2),
      'otherQualification': [],
      'jobPositions': getRandom(position, 2),
      'availability': true,
      'rating': getRandom(rating, 1),
      'currentLocation': getRandom(location, 1),
      'profileImage': '',
      'reference': worker.reference,
      'category': getRandom(category, 1),
      'address': '',
      'mobileNo': '',
      'email': worker.email,
    };

    return Worker.fromMap(random);
  }

  getRandom(List list, int limit) {
    final _random = new Random();
    if (limit == 1) {
      return list[_random.nextInt(list.length)];
    } else {
      return list.sublist(_random.nextInt(list.length));
    }
  }
}
