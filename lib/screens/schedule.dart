import 'package:TolongApp/blocs/helper_bloc.dart';
import 'package:TolongApp/blocs/schedule_bloc.dart';
import 'package:TolongApp/models/schedule.dart';
import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/utils/time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  final String uid;
  ScheduleScreen({Key key, this.uid}) : super(key: key);

  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _bloc = ScheduleBloc();
  final _helperBloc = HelperBloc();
  var _formatter = new DateFormat('dd-MM-yyyy');
  String todayDate;
  String tomorrowDate;
  String dayAfterTomorrowDate;
  bool showTodaySchedule = true;
  bool showTomorrowSchedule = false;
  bool showDayAfterTomorrowSchedule = false;

  String selectedFromTime = '0:00';
  String selectedToTime = '0:00';
  int selectedDuration = 0;
  TimeOfDay fromTimeOfDay;
  TimeOfDay toTimeOfDay;
  bool isEditingSchedule = false;
  bool isUpdatingSchedule = false;

  TimeFormatter _timeFormatter = new TimeFormatter();
  List<DocumentSnapshot> todaySchedule = new List();
  List<DocumentSnapshot> tomorrowSchedule = new List();
  List<DocumentSnapshot> dayAfterTomorrowSchedule = new List();
  Map<String, List<DocumentSnapshot>> fullSchedule = new Map();

  void _getScheduleTime(BuildContext context, bool isFromTime) async {
    var time = await showTimePicker(
        context: context,
        initialTime: isFromTime ? fromTimeOfDay : toTimeOfDay);

    setState(() {
      if (time != null) {
        var selectedTime =
            _timeFormatter.getFormattedTime(time.hour, time.minute);

        if (isFromTime) {
          selectedFromTime = selectedTime;
          fromTimeOfDay = time;
        } else {
          selectedToTime = selectedTime;
          toTimeOfDay = time;
        }

        if (fromTimeOfDay != null && toTimeOfDay != null) {
          bool isBefore;

          if (toTimeOfDay.hour > fromTimeOfDay.hour) {
            print('valid time');
          } else {
            print('invalid time');
          }

          if (toTimeOfDay.hour == fromTimeOfDay.hour) {
            if (toTimeOfDay.minute > fromTimeOfDay.minute) {
              print('valid minute');
            } else {
              print('invalid minute');
            }
          }
        }
      } else {
        selectedFromTime = '0:00';
        selectedToTime = '0:00';
      }
    });
  }

  void addSchedule() async {
    int dateInSeconds = 0;
    if (showTodaySchedule) {
      dateInSeconds = DateTime.now().millisecondsSinceEpoch;
    }

    if (showTomorrowSchedule) {
      dateInSeconds =
          DateTime.now().add(new Duration(days: 1)).millisecondsSinceEpoch;
    }

    if (showDayAfterTomorrowSchedule) {
      dateInSeconds =
          DateTime.now().add(new Duration(days: 2)).millisecondsSinceEpoch;
    }

    Schedule schedule = new Schedule(
        widget.uid,
        new Timestamp.fromMillisecondsSinceEpoch(dateInSeconds),
        toTimeOfDay.hour - fromTimeOfDay.hour,
        selectedFromTime + ' - ' + selectedToTime,
        '');
    _bloc.addSchedule(schedule);

    if (showTodaySchedule) {
      await _updateHelperAvailability(true);
    }
  }

  Future _updateHelperAvailability(bool isAvailable) async {
    var snapshot = await _helperBloc.getHelperById(widget.uid);
    snapshot.data.update('availability', (data) => isAvailable);
    _helperBloc.updateHelper(snapshot, Worker.fromSnapshot(snapshot));
  }

  void deleteSchedule(DocumentSnapshot schedule) {
    _bloc.deleteSchedule(schedule);
  }

  void updateSchedule(DocumentSnapshot snapshot, Schedule schedule) {
    _bloc.updateSchedule(snapshot, schedule).then((updated) {
      print(updated);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      todayDate = _formatter.format(DateTime.now());
      tomorrowDate =
          _formatter.format(DateTime.now().add(new Duration(days: 1)));
      dayAfterTomorrowDate =
          _formatter.format(DateTime.now().add(new Duration(days: 2)));
      selectedFromTime = '0:00';
      selectedToTime = '0:00';
    });

    _bloc.getLatestSchedule(widget.uid);
    _bloc.getSchedules.listen((data) {
      populateLatestSchedules(
          data, todayDate, tomorrowDate, dayAfterTomorrowDate);
    });
  }

  void populateLatestSchedules(QuerySnapshot data, String todayDate,
      String tomorrowDate, String dayAfterTomorrowDate) {
    setState(() {
      selectedFromTime = '0:00';
      selectedToTime = '0:00';
      fromTimeOfDay = new TimeOfDay(hour: 0, minute: 0);
      toTimeOfDay = new TimeOfDay(hour: 0, minute: 0);
    });
    if (data.documents.isNotEmpty) {
      todaySchedule = [];
      tomorrowSchedule = [];
      dayAfterTomorrowSchedule = [];
      data.documents.forEach((schedule) {
        var data = Schedule.fromSnapshot(schedule);
        var date = _formatter.format(data.dates.toDate());
        if (date == todayDate) {
          setState(() {
            todaySchedule.add(schedule);
          });
        }

        if (date == tomorrowDate) {
          setState(() {
            tomorrowSchedule.add(schedule);
          });
        }

        if (date == dayAfterTomorrowDate) {
          setState(() {
            dayAfterTomorrowSchedule.add(schedule);
          });
        }
      });

      setState(() {
        fullSchedule.putIfAbsent(todayDate, () => todaySchedule);
        fullSchedule.putIfAbsent(tomorrowDate, () => tomorrowSchedule);
        fullSchedule.putIfAbsent(
            dayAfterTomorrowDate, () => dayAfterTomorrowSchedule);
      });
    } else {
      setState(() {
        todaySchedule = [];
        tomorrowSchedule = [];
        dayAfterTomorrowSchedule = [];
      });
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        buildScheduleSelection(),
        showTodaySchedule
            ? displayTodaySchedule()
            : SizedBox(
                height: 0,
              ),
        showTomorrowSchedule
            ? displayTomorrowSchedule()
            : SizedBox(
                height: 0,
              ),
        showDayAfterTomorrowSchedule
            ? displayDayAfterTomorrowSchedule()
            : SizedBox(
                height: 0,
              ),
        SizedBox(height: 25.0),
        isEditingSchedule
            ? displayScheduleForm(context)
            : SizedBox(
                height: 0.0,
              ),
        displayScheduleFormButton(context),
      ],
    ));
  }

  Widget displayScheduleFormButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            if (isEditingSchedule) {
              addSchedule();
            }
            setState(() {
              isEditingSchedule = !isEditingSchedule;
            });
          },
          padding: EdgeInsets.all(12),
          color: Color.fromARGB(255, 106, 187, 67),
          child: isEditingSchedule
              ? Text('Save', style: TextStyle(color: Colors.white))
              : Text('Add Schedule', style: TextStyle(color: Colors.white)),
        ),
        SizedBox(
          width: 15.0,
        ),
        isEditingSchedule
            ? showCancelButton()
            : SizedBox(
                height: 0,
              )
      ],
    );
  }

  RaisedButton showCancelButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onPressed: () {
        setState(() {
          isEditingSchedule = false;
          selectedFromTime = '0:00';
          selectedToTime = '0:00';
        });
      },
      padding: EdgeInsets.all(12),
      color: Colors.red,
      child: Text('Cancel', style: TextStyle(color: Colors.white)),
    );
  }

  Widget displayScheduleForm(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('From'),
            Container(
              padding: EdgeInsets.all(6.0),
              width: MediaQuery.of(context).size.width * 0.2,
              color: Colors.grey,
              child: GestureDetector(
                onTap: () {
                  _getScheduleTime(context, true);
                },
                child: Center(child: Text(selectedFromTime)),
              ),
            ),
            Text('To'),
            Container(
              padding: EdgeInsets.all(6.0),
              width: MediaQuery.of(context).size.width * 0.2,
              color: Colors.grey,
              child: GestureDetector(
                onTap: () {
                  _getScheduleTime(context, false);
                },
                child: Center(child: Text(selectedToTime)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView buildTodaySchedule() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: todaySchedule.length,
      itemBuilder: (BuildContext context, int index) {
        Schedule schedule = Schedule.fromSnapshot(todaySchedule[index]);
        return Container(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(schedule.range),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        deleteSchedule(todaySchedule[index]);
                        if (todaySchedule.contains(todaySchedule[index])) {
                          todaySchedule.removeAt(index);
                          if (todaySchedule.isEmpty) {
                            _updateHelperAvailability(false);
                          }
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  ListView buildTomorrowSchedule() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: tomorrowSchedule.length,
      itemBuilder: (BuildContext context, int index) {
        Schedule schedule = Schedule.fromSnapshot(tomorrowSchedule[index]);
        return Container(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(schedule.range),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        deleteSchedule(tomorrowSchedule[index]);
                        if (tomorrowSchedule
                            .contains(tomorrowSchedule[index])) {
                          tomorrowSchedule.removeAt(index);
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  ListView buildDayAfterTomorrowSchedule() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: dayAfterTomorrowSchedule.length,
      itemBuilder: (BuildContext context, int index) {
        Schedule schedule =
            Schedule.fromSnapshot(dayAfterTomorrowSchedule[index]);
        return Container(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(schedule.range),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        deleteSchedule(dayAfterTomorrowSchedule[index]);
                        if (dayAfterTomorrowSchedule
                            .contains(dayAfterTomorrowSchedule[index])) {
                          dayAfterTomorrowSchedule.removeAt(index);
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget displayTodaySchedule() {
    return todaySchedule.isNotEmpty
        ? buildTodaySchedule()
        : Text('No schedule set for ' + todayDate);
  }

  Widget displayTomorrowSchedule() {
    return tomorrowSchedule.isNotEmpty
        ? buildTomorrowSchedule()
        : Text('No schedule set for ' + tomorrowDate);
  }

  Widget displayDayAfterTomorrowSchedule() {
    return dayAfterTomorrowSchedule.isNotEmpty
        ? buildDayAfterTomorrowSchedule()
        : Text('No schedule set for ' + dayAfterTomorrowDate);
  }

  Row buildScheduleSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            setState(() {
              showTodaySchedule = true;
              showTomorrowSchedule = false;
              showDayAfterTomorrowSchedule = false;
            });
          },
          child: showTodaySchedule
              ? Text(
                  todayDate,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                )
              : Text(
                  todayDate,
                  style: TextStyle(color: Colors.grey),
                ),
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              showTodaySchedule = false;
              showTomorrowSchedule = true;
              showDayAfterTomorrowSchedule = false;
            });
          },
          child: showTomorrowSchedule
              ? Text(
                  tomorrowDate,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                )
              : Text(
                  tomorrowDate,
                  style: TextStyle(color: Colors.grey),
                ),
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              showTodaySchedule = false;
              showTomorrowSchedule = false;
              showDayAfterTomorrowSchedule = true;
            });
          },
          child: showDayAfterTomorrowSchedule
              ? Text(
                  dayAfterTomorrowDate,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                )
              : Text(
                  dayAfterTomorrowDate,
                  style: TextStyle(color: Colors.grey),
                ),
        )
      ],
    );
  }
}
