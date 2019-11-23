import 'dart:async';

import 'package:TolongApp/models/schedule.dart';
import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/models/task.dart';
import 'package:TolongApp/screens/job_accepted.dart';
import 'package:TolongApp/services/schedules.dart';
import 'package:TolongApp/services/tasks.dart';
import 'package:TolongApp/utils/list_utils.dart';
import 'package:TolongApp/widgets/rating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HelperDetailScreen extends StatefulWidget {
  final Worker worker;
  HelperDetailScreen({Key key, @required this.worker}) : super(key: key);
  @override
  _HelperDetailScreenState createState() => _HelperDetailScreenState();
}

class ProfileSection extends StatelessWidget {
  final String title;
  final String description;
  ProfileSection({Key key, this.title, this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style:
                    TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                description,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelperDetailScreenState extends State<HelperDetailScreen> {
  TaskService db = new TaskService();
  List<Task> tasks;
  StreamSubscription<QuerySnapshot> taskSub;

  ScheduleService scheduleService = new ScheduleService();
  List<Schedule> schedules;
  StreamSubscription<QuerySnapshot> scheduleSub;

  bool showSchedule = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.worker.firstName + ' ' + widget.worker.lastName),
      ),
      body: Container(
          child: SingleChildScrollView(
              child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage(widget.worker.profileImage),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Center(
                child: new RatingWidget(rating: widget.worker.rating),
              ),
            ),
            Center(
              child: Text(
                ListUtils.parseListToString(widget.worker.jobPosition),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            Center(
              child: Text(
                widget.worker.firstName + ' ' + widget.worker.lastName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _changedView(true);
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('View Schedule')
                      ],
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        _changedView(false);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.verified_user,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('View Full Profile')
                        ],
                      )),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 2.0,
            ),
            showSchedule ? showScheduleView() : showProfileView(),
            Divider(
              color: Colors.grey,
              height: 2.0,
            ),
            showSchedule
                ? SizedBox(
                    height: 0,
                  )
                : showLastTaskView(),
          ],
        ),
      ))),
    );
  }

  @override
  void initState() {
    super.initState();

    // Fetch helpers details
    setUpTaskList();

    setUpScheduleList();
  }

  void setUpScheduleList() {
    schedules = new List();
    scheduleSub?.cancel();
    scheduleSub =
        scheduleService.getScheduleList().listen((QuerySnapshot snapshot) {
      final List<Schedule> initSchedules = snapshot.documents
          .map((documentSnapshot) => Schedule.fromMap(documentSnapshot.data))
          .toList();

      final List<Schedule> filteredSchedules = initSchedules.where((schedule) {
        if (schedule.reference.trim() == widget.worker.reference) {
          return true;
        }
        return false;
      }).toList();
      setState(() {
        this.schedules = filteredSchedules;
      });
    });
  }

  void setUpTaskList() {
    tasks = new List();
    taskSub?.cancel();
    taskSub = db.getTaskList().listen((QuerySnapshot snapshot) {
      final List<Task> notes = snapshot.documents
          .map((documentSnapshot) => Task.fromMap(documentSnapshot.data))
          .toList();

      final List<Task> filteredTasks = notes.where((task) {
        print(
            'checking task ${task.reference} ====================================');
        if (task.reference.trim() == widget.worker.reference) {
          return true;
        }
        return false;
      }).toList();
      print('length of filtered list ${filteredTasks.length}');
      setState(() {
        this.tasks = filteredTasks;
      });
    });
  }

  Widget showLastTaskView() {
    List<Widget> rows = new List();
    if (this.tasks.length > 0) {
      rows.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[Text('Last ${this.tasks.length} Tasks')],
        ),
      ));
      for (var task in this.tasks) {
        rows.add(_buildTaskRow(task));
      }
    }
    return Column(
      children: rows,
    );
  }

  Widget showProfileView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProfileSection(
                title: 'Full Name',
                description:
                    widget.worker.firstName + ' ' + widget.worker.lastName,
              ),
              ProfileSection(
                title: 'Age',
                description: widget.worker.age.toString(),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProfileSection(
                title: 'Academic Qualifications',
                description: ListUtils.parseListToString(
                    widget.worker.academicQualification),
              ),
              ProfileSection(
                title: 'Other Qualification',
                description: ListUtils.parseListToString(
                    widget.worker.otherQualification),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget showScheduleView() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('TODAY'),
            Container(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[500],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                      right: 16.0,
                                      bottom: 8.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('2HRs'),
                                    Text('8.00AM - 10.00AM')
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.green[500],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                      right: 16.0,
                                      bottom: 8.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: GestureDetector(
                                        onTap: () {}, child: Icon(Icons.check)),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('2HRs'),
                                    Text('12.00PM - 2.00AM')
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[500],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                      right: 16.0,
                                      bottom: 8.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Icon(Icons.check,
                                            color: Colors.white)),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('2HRs'),
                                    Text('02.00PM - 4.00PM')
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[500],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                      right: 16.0,
                                      bottom: 8.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('4HRs'),
                                    Text('6.00PM - 10.00PM')
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Text('TOMORROW'),
            Container(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[500],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                      right: 16.0,
                                      bottom: 8.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('2HRs'),
                                    Text('8.00AM - 10.00AM')
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.green[500],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                      right: 16.0,
                                      bottom: 8.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: GestureDetector(
                                        onTap: () {}, child: Icon(Icons.check)),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('2HRs'),
                                    Text('12.00PM - 2.00AM')
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[500],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                      right: 16.0,
                                      bottom: 8.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('2HRs'),
                                    Text('02.00PM - 4.00PM')
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[500],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                      right: 16.0,
                                      bottom: 8.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          key: Key('value'),
                                        )),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('4HRs'),
                                    Text('6.00PM - 10.00PM')
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Text('Choosen Hours: 4'),
                SizedBox(
                  height: 34.0,
                ),
                Text('Total Payment'),
                Text(
                  'RM32',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => JobAcceptedPage()));
                    },
                    padding: EdgeInsets.all(12),
                    color: Color.fromARGB(255, 106, 187, 67),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('MAKE A REQUEST',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTaskRow(Task task) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title[0].toUpperCase() + task.title.substring(1),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    new RatingWidget(
                      rating: task.rating,
                      alignCenter: false,
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.black54,
                        size: 16.0,
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Text(
                        task.location,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Divider(
          height: 2.0,
          color: Colors.grey,
        )
      ],
    );
  }

  void _changedView(bool visibility) {
    setState(() {
      showSchedule = visibility;
    });
  }
}
