import 'package:TolongApp/blocs/helper_bloc.dart';
import 'package:TolongApp/blocs/location_bloc.dart';
import 'package:TolongApp/blocs/task_bloc.dart';
import 'package:TolongApp/models/task.dart';
import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/screens/earnings.dart';
import 'package:TolongApp/screens/profile.dart';
import 'package:TolongApp/screens/schedule.dart';
import 'package:TolongApp/services/authentication.dart';
import 'package:TolongApp/services/geolocator.dart';
import 'package:TolongApp/services/preferences.dart';
import 'package:TolongApp/services/uploader.dart';
import 'package:TolongApp/services/workers.dart';
import 'package:TolongApp/widgets/home/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class HomeScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  const HomeScreen({Key key, this.auth, this.onSignedOut}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _bloc = HelperBloc();
  final _taskBloc = TaskBloc();
  final _locationBloc = LocationBloc();
  UploaderService uploader = new UploaderService();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  GeolocatorService geoService = new GeolocatorService();
  WorkerService workerService = new WorkerService();
  Worker worker;
  DocumentSnapshot snapshot;
  QuerySnapshot tasksSnapshot;

  List<Tab> tabs;
  TabController _tabController;

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
                child: Image(
              fit: BoxFit.contain,
              image: AssetImage('assets/images/logos/logo.png'),
            )),
          ),
          title: Text(worker?.firstName ?? 'hello'),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  _scaffoldKey.currentState.openEndDrawer();
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ))
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: tabs,
          ),
        ),
        endDrawer: HomeDrawer(
          auth: widget.auth,
          onSignedOut: widget.onSignedOut,
          worker: worker,
        ),
        body: _buildHomeBody());
  }

  Widget _buildHomeBody() {
    if (worker != null) {
      return TabBarView(
        controller: _tabController,
        children: tabs.map((Tab tab) {
          switch (tab.text) {
            case 'Edit Profile':
              return ProfileScreen(
                worker: worker,
                snapshot: snapshot,
              );
              break;
            case 'Add Schedule':
              return ScheduleScreen(
                uid: snapshot.documentID,
              );
              break;
            case 'View Earnings':
              return EarningsScreen(
                uid: snapshot.documentID,
              );
              break;
            default:
              return Center(child: Text(tab.text));
          }
        }).toList(),
      );
    }
    return Center(child: CircularProgressIndicator());
  }

  void populateCurrentHelper() async {
    String uid = await preferences.getHelperId();
    if (uid != null && uid.isNotEmpty) {
      _taskBloc.getTasksById(uid);
      _bloc.getHelperWithId(uid);
      _taskBloc.getTasks.listen((snapshot) {
        setState(() {
          tasksSnapshot = snapshot;
        });
        print(snapshot.documents.last.data['status']);
        if (_notification == AppLifecycleState.paused &&
            snapshot.documents.last.data['status'] == 'new') {
          _showNotification(snapshot.documents.last);
        }

        if ((_notification == null ||
            _notification == AppLifecycleState.resumed) &&
            snapshot.documents.last.data['status'] == 'new') {
          _showTaskDialog(snapshot.documents.last);
        }
      });
    }
    if (uid == null || uid.isEmpty) {
      await widget.auth.getCurrentUser().then((user) {
        if (user != null && user.email.isNotEmpty) {
          _bloc.getHelperWithEmail(user.email).then((uid) {
            _bloc.getHelperWithId(uid);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.dispose();
    _locationBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      tabs = <Tab>[
        Tab(text: 'Edit Profile'),
        Tab(text: 'Add Schedule'),
        Tab(text: 'View Earnings'),
      ];
      _tabController = TabController(vsync: this, length: tabs.length);
    });
    initializeLocalNotification();
    populateCurrentHelper();
    _bloc.getWorker.listen((snapshot) {
      setState(() {
        this.snapshot = snapshot;
        worker = Worker.fromSnapshot(snapshot);
      });
    });


    _locationBloc.getCurrentLocation();
    _locationBloc.getLocation.listen((position) {
      if (snapshot != null && snapshot.data['currentLocation'] != null) {
        GeoPoint current = snapshot.data['currentLocation'];
        if (current.latitude != position.latitude ||
            current.longitude != position.longitude) {
          snapshot.data['currentLocation'] =
              new GeoPoint(position.latitude, position.longitude);
          _bloc.updateHelper(snapshot, Worker.fromSnapshot(snapshot));
        }
      }
    });
  }

  void _showTaskDialog(DocumentSnapshot snapshot) {
    Task task = Task.fromSnapshot(snapshot);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("New Job Request"),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(task.title),
                Text(task.description),
                Text(task.location),
                Text('RM ' + task.price)
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Accept"),
              onPressed: () {
                task.isNotifiedField = true;
                task.isRepliedField = true;
                task.statusField = 'accepted';
                _taskBloc.updateTask(snapshot, task).whenComplete(() {
                  Navigator.of(context).pop();
                });
              },
            ),
            new FlatButton(
              child: new Text("Reject"),
              onPressed: () {
                task.isNotifiedField = true;
                task.isRepliedField = true;
                task.statusField = 'rejected';
                _taskBloc.updateTask(snapshot, task).whenComplete(() {
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void initializeLocalNotification() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidRecieveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future _showNotification(DocumentSnapshot snapshot) async {
    Task task = Task.fromSnapshot(snapshot);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, task.title, task.description, platformChannelSpecifics,
        payload: snapshot.documentID);
  }

  Future onDidRecieveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
            title: new Text(title),
            content: new Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text('Ok'),
                onPressed: () async {
                  print('onDidReceiveLocalNotification');
                },
              )
            ],
          ),
    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    print('onSelectNotification');
    var task =
        tasksSnapshot.documents.singleWhere((doc) => doc.documentID == payload);
    if (task != null && task.exists) {
      _showTaskDialog(task);
    }
  }
}
