import 'package:TolongApp/blocs/task_bloc.dart';
import 'package:TolongApp/models/task.dart';
import 'package:TolongApp/services/preferences.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key key}) : super(key: key);
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _bloc = TaskBloc();
  List<Task> _allTasks;

  @override
  void initState() {
    super.initState();
    setState(() {
      _allTasks = new List();
    });
    initializeBloc();
    _bloc.getTasks.listen((snapshot) {
      setState(() {
        _allTasks =
            snapshot.documents.map((doc) => Task.fromSnapshot(doc)).toList();
      });
    });
  }

  void initializeBloc() async {
    String uid = await preferences.getHelperId();
    _bloc.getTasksById(uid);
  }

  Widget _buildCurrentTask() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _getCurrentTask(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTask() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _getCompletedTask(),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _getCurrentTask() {
    List<Task> currentTask = _allTasks
        .where(
            (task) => task.status != 'completed' && task.status != 'cancelled')
        .toList();
    List<Widget> tasks =
        currentTask.map((task) => _buildTaskCard(task)).toList();
    print('in progress task ' + currentTask.length.toString());
    return tasks;
  }

  List<Widget> _getCompletedTask() {
    List<Task> currentTask = _allTasks
        .where(
            (task) => task.status == 'completed' || task.status == 'cancelled')
        .toList();
    List<Widget> tasks =
        currentTask.map((task) => _buildTaskCard(task)).toList();
    print('completed task ' + currentTask.length.toString());
    return tasks;
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 5.0,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                task.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(task.description),
              Text(task.location),
              Text('Status: ' + task.status?.toUpperCase()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Text('Employer: ' + task.reference),
                  Text('Price: RM8/Hrs')
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        // The number of tabs / content sections we need to display
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Center(child: Text('Current Tasks'))),
                Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Center(child: Text('Completed Tasks'))),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              _buildCurrentTask(),
              _buildCompletedTask(),
            ],
          ),
        ));
  }
}
