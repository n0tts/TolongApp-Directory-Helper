import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String _title;
  String _description;
  String _location;
  String _reference;
  String _worker;
  String _duration;
  String _price;
  String _helperName;
  int ratingCount;
  String statusField;
  bool isNotifiedField;
  bool isRepliedField;

  Task(
      this._title,
      this._description,
      this._location,
      this._reference,
      this._worker,
      this._duration,
      this._price,
      this._helperName,
      this.statusField,
      this.isNotifiedField,
      this.isRepliedField,
      {this.ratingCount});

  Task.fromMap(Map<String, dynamic> map) {
    this._title = map['title'];
    this._description = map['description'];
    this._location = map['location'];
    this._reference = map['reference'];
    this._worker = map['worker'];
    this._price = map['price'];
    this._duration = map['duration'];
    this._helperName = map['helperName'];
    this.statusField = map['status'];
    this.isNotifiedField = map['isNotified'];
    this.isRepliedField = map['isReplied'];
    this.ratingCount = map['rating'];
  }

  Task.map(dynamic json) {
    this._title = json['title'];
    this._description = json['description'];
    this._location = json['location'];
    this._reference = json['reference'];
    this._worker = json['worker'];
    this.statusField = json['status'];
    this.isNotifiedField = json['isNotified'];
    this.isRepliedField = json['isReplied'];
    this.ratingCount = json['rating'];
    this._price = json['price'];
    this._duration = json['duration'];
    this._helperName = json['helperName'];
  }

  String get description => _description;
  String get location => _location;
  int get rating => ratingCount;
  String get reference => _reference;
  String get title => _title;
  String get worker => _worker;
  String get status => statusField;
  bool get isNotified => isNotifiedField;
  bool get isReplied => isRepliedField;
  String get duration => _duration;
  String get price => _price;
  String get helperName => _helperName;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['title'] = _title;
    map['description'] = _description;
    map['location'] = _location;
    map['rating'] = ratingCount;
    map['reference'] = _reference;
    map['worker'] = _worker;
    map['status'] = status;
    map['isNotified'] = isNotifiedField;
    map['isReplied'] = isRepliedField;
    map['duration'] = _duration;
    map['price'] = _price;
    map['helperName'] = _helperName;
    return map;
  }

  Task.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}
