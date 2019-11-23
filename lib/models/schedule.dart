import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  String _reference;
  Timestamp _dates;
  num _duration;
  String _range;
  String _task;

  Schedule(
      this._reference, this._dates, this._duration, this._range, this._task);

  Schedule.fromMap(Map<String, dynamic> map) {
    this._reference = map['reference'];
    this._dates = map['dates'];
    this._duration = map['duration'];
    this._range = map['range'];
    this._task = map['task'];
  }

  Timestamp get dates => _dates;
  num get duration => _duration;
  String get range => _range;
  String get reference => _reference;
  String get task => _task;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['reference'] = _reference;
    map['dates'] = _dates;
    map['duration'] = _duration;
    map['range'] = _range;
    map['task'] = _task;
    return map;
  }

  Schedule.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}
