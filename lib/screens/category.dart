import 'dart:async';

import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/services/geolocator.dart';
import 'package:TolongApp/services/helpers.dart';
import 'package:TolongApp/widgets/helper_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  final bool isAnonymous;

  CategoryScreen({Key key, @required this.title, this.isAnonymous})
      : super(key: key);
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  HelperService db = new HelperService();
  List<Worker> items;
  GeolocatorService geolocatorService = new GeolocatorService();
  Position currentPosition = new Position(latitude: 0, longitude: 0);

  StreamSubscription<QuerySnapshot> helperSub;
  StreamSubscription<QuerySnapshot> ratingSub;
  StreamSubscription<QuerySnapshot> nearbySub;
  StreamSubscription<QuerySnapshot> availabilitySub;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Material(
        child: Column(
          children: <Widget>[
            Image.asset(
              'assets/images/mountains.jpeg',
              height: MediaQuery.of(context).size.height / 3.5,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Pricing',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.08,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border(left: BorderSide(width: 1.0))),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Availability',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: this.items.length,
                itemBuilder: (context, index) {
                  return helperCard(context, this.items[index],
                      widget.isAnonymous ? false : true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    geolocatorService.getCurrentPosition().then((position) {
      print(position.latitude.toString() +
          '=========================================');
      setState(() {
        currentPosition = position;
        print(
            'current position is set at ${currentPosition.latitude.toString()}');
      });
    });
    String anonymous = widget.isAnonymous.toString();
    print('is Anonymous: $anonymous');

    // Fetch helpers details
    items = new List();
    helperSub?.cancel();
    helperSub = db
        .getHelperListByCategory(widget.title.toLowerCase())
        .listen((QuerySnapshot snapshot) {
      final List<Worker> notes = snapshot.documents
          .map((documentSnapshot) => Worker.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this.items = notes;
        print('items length ${this.items.length}');
        print('items 1: ${this.items[0].firstName}');
      });
    });
  }

  void onAvailabilitySubmitted(query) {
    availabilitySub?.cancel();
    availabilitySub = db
        .getHelperListByAvailability(query, widget.title.toLowerCase())
        .listen((QuerySnapshot snapshot) {
      final List<Worker> notes = snapshot.documents
          .map((documentSnapshot) => Worker.fromMap(documentSnapshot.data))
          .toList();
      print('search result ============');
      if (notes.length > 0) {
        setState(() {
          this.items = notes;
        });
      }
    });
  }

  void onNearbySubmitted(query) {
    nearbySub?.cancel();
    nearbySub = db
        .getHelperListByCategory(widget.title.toLowerCase())
        .listen((QuerySnapshot snapshot) {
      final List<Worker> notes = snapshot.documents
          .map((documentSnapshot) => Worker.fromMap(documentSnapshot.data))
          .toList();
      if (notes.length > 0) {
        geolocatorService
            .getMatchedDistance(currentPosition, notes, query)
            .then((workers) {
          setState(() {
            this.items = workers;
          });
        }).whenComplete(() {
          print('check distance completed');
        });
      }
    });
  }

  void onRatingSubmitted(query) {
    ratingSub?.cancel();
    ratingSub = db
        .getHelperListByRating(query, widget.title.toLowerCase())
        .listen((QuerySnapshot snapshot) {
      final List<Worker> notes = snapshot.documents
          .map((documentSnapshot) => Worker.fromMap(documentSnapshot.data))
          .toList();
      print('search result ============');
      if (notes.length > 0) {
        setState(() {
          this.items = notes;
        });
      }
    });
  }
}
