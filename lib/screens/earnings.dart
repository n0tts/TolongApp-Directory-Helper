import 'package:TolongApp/blocs/earning_bloc.dart';
import 'package:TolongApp/models/earning.dart';
import 'package:TolongApp/services/earnings.dart';
import 'package:TolongApp/widgets/rating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'package:TolongApp/utils/time_utils.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class EarningsScreen extends StatefulWidget {
  final String uid;
  EarningsScreen({Key key, this.uid}) : super(key: key);

  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final _bloc = EarningBloc();
  List<DocumentSnapshot> _earnings = [];
  Map<DateTime, List<Earning>> _sortedEarnings = new Map();
  DateTime _selectedEarningDate;
  EarningService earningService = new EarningService();

  @override
  void initState() {
    super.initState();
    setState(() {
      _earnings = [];
      _sortedEarnings = new Map();
    });
    _bloc.getHelperEarnings(widget.uid);
    _bloc.getEarnings.listen((earnings) {
      if (earnings.documents.isNotEmpty) {
        setState(() {
          _earnings.clear();
          _earnings = earnings.documents;
          _sortedEarnings.clear();
          _earnings.forEach((doc) {
            sortEarnings(Earning.fromSnapshot(doc));
          });
        });
      }
    });
  }

  void sortEarnings(Earning earning) {
    DateTime dateTime = new DateTime.fromMillisecondsSinceEpoch(
        earning.date.millisecondsSinceEpoch);
    List<Earning> earnings = [];
    earnings.add(earning);

    if (_sortedEarnings.containsKey(dateTime)) {
      _sortedEarnings[dateTime].add(earning);
    }

    _sortedEarnings.putIfAbsent(dateTime, () => earnings);
    print(_sortedEarnings[dateTime].length);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 25.0, left: 8.0, right: 8.0),
        child: displaySortedEarnings(),
      ),
    );
  }

  Widget displaySortedEarnings() {
    if (_sortedEarnings.isEmpty) {
      return Center(
        child: Text('There is no earnings yet.'),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.width * 0.2,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: _sortedEarnings.length,
                itemBuilder: (BuildContext context, index) {
                  var keys = _sortedEarnings.keys.elementAt(index);
                  print(keys);
                  return Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border(
                              top: BorderSide(color: Colors.grey),
                              right: BorderSide(color: Colors.grey),
                              left: BorderSide(color: Colors.grey),
                              bottom: BorderSide(color: Colors.orange))),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEarningDate = keys;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(timeFormatter.getMonthString(keys.month)),
                            SizedBox(
                              height: 6.0,
                            ),
                            Text(keys.day.toString()),
                            Text(timeFormatter.getWeekdayString(keys.weekday))
                          ],
                        ),
                      ));
                },
              )),
          _buildSelectedEarningView(_selectedEarningDate)
        ],
      );
    }
  }

  Widget _buildSelectedEarningView(DateTime key) {
    if (_selectedEarningDate == null) {
      setState(() {
        _selectedEarningDate = _sortedEarnings.keys.elementAt(0);
        key = _sortedEarnings.keys.elementAt(_sortedEarnings.length - 1);
      });
    }

    if (_selectedEarningDate != null) {
      var count = _sortedEarnings[key].length;
      num total = _sortedEarnings[key]
          .fold(0, (prev, earning) => prev + earning.earning);
      List<Earning> earnings = _sortedEarnings[key];
      return Column(
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          Container(
            color: Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'WAGES',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        total.toStringAsFixed(2),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 35.0),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('PAID ON'),
                          Text(new DateFormat('dd MMM yyyy').format(key),
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Text('${count.toString()} Jobs Completed'),
          SizedBox(
            height: 16.0,
          ),
          _buildList(earnings)
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _buildList(List<Earning> earning) {
    return ListView(
      shrinkWrap: true,
      children: earning.map((data) => _buildListItem(data)).toList(),
    );
  }

  Widget _buildListItem(Earning earning) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(earning.time,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(earning.task,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 25.0)),
                    Text(earning.earning.toStringAsFixed(2),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 35.0)),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                RatingWidget(
                  rating: earning.rating,
                  alignCenter: false,
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 16.0,
        )
      ],
    );
  }
}
