import 'package:TolongApp/screens/job_completed.dart';
import 'package:flutter/material.dart';

class JobAcceptedPage extends StatefulWidget {
  JobAcceptedPage({Key key}) : super(key: key);

  _JobAcceptedPageState createState() => _JobAcceptedPageState();
}

class _JobAcceptedPageState extends State<JobAcceptedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 35.0,
                ),
                Text('John Jimmy Lee',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 24.0,
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45.0),
                  child: Text(
                    'Have accepted the job offer',
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                )),
                SizedBox(
                  height: 24.0,
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0),
                  child: Text(
                    'Estimate Arrival Time in:',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                )),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0),
                  child: Text(
                    '60Mins',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )),
                SizedBox(
                  height: 24.0,
                ),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                  ),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(
                  height: 10.0,
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
                              builder: (context) => JobCompletedPage()));
                    },
                    color: Color.fromARGB(255, 106, 187, 67),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('SEND MESSAGE',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
