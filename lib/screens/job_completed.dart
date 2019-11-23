import 'package:flutter/material.dart';

class JobCompletedPage extends StatefulWidget {
  final Widget child;

  JobCompletedPage({Key key, this.child}) : super(key: key);

  _JobCompletedPageState createState() => _JobCompletedPageState();
}

class _JobCompletedPageState extends State<JobCompletedPage> {
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
                    'Have arrived & started Work',
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
                    'Clock In',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                )),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0),
                  child: Text(
                    '12.00PM',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
                    'Clock Out',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                )),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0),
                  child: Text(
                    '2.00PM',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )),
                 SizedBox(
                  height: 40.0,
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0),
                  child: Text(
                    'Total Hours',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                )),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0),
                  child: Text(
                    '4.00 Hours',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 225, 109, 69)),
                    textAlign: TextAlign.center,
                  ),
                )),
                SizedBox(
                  height: 24.0,
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
                      child: Text('CONFIRM & RELEASE PAYMENT',
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
