import 'package:cloud_firestore/cloud_firestore.dart';

class Earning {
  num earningField;
  String employerField;
  String workerField;
  int ratingField;
  String timeField;
  Timestamp dateField;
  String taskField;

  Earning(
      {this.earningField,
      this.employerField,
      this.ratingField,
      this.timeField,
      this.dateField,
      this.workerField,
      this.taskField});

  Earning.fromMap(Map<String, dynamic> map) {
    this.earningField = map['earning'];
    this.taskField = map['task'];
    this.ratingField = map['rating'];
    this.employerField = map['employer'];
    this.workerField = map['worker'];
    this.timeField = map['time'];
    this.dateField = map['date'];
  }

  Earning.map(dynamic json) {
    this.earningField = json['earning'];
    this.taskField = json['task'];
    this.ratingField = json['rating'];
    this.employerField = json['employer'];
    this.workerField = json['worker'];
    this.timeField = json['time'];
    this.dateField = json['date'];
  }

  String get time => timeField;
  int get rating => ratingField;
  num get earning => earningField;
  String get employer => employerField;
  String get worker => workerField;
  Timestamp get date => dateField;
  String get task => taskField;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['rating'] = ratingField;
    map['employer'] = employerField;
    map['task'] = taskField;
    map['time'] = timeField;
    map['date'] = dateField;
    map['worker'] = workerField;
    map['earning'] = earningField;

    return map;
  }

  Earning.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}
