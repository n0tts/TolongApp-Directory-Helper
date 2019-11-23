import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/screens/settings.dart';
import 'package:TolongApp/screens/tasks.dart';
import 'package:TolongApp/services/authentication.dart';
import 'package:TolongApp/services/preferences.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeDrawer extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final Worker worker;
  final String uid;

  HomeDrawer({Key key, this.auth, this.onSignedOut, this.worker, this.uid})
      : super(key: key);

  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  String displayName;

  @override
  void initState() {
    super.initState();
    setState(() {
      displayName = 'Welcome';
      if (widget.worker != null && widget.worker.displayName.isNotEmpty) {
        displayName = widget.worker.displayName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 20.0,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Center(
              child: Container(
                width: double.infinity,
                color: Color.fromARGB(255, 225, 109, 69),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                          radius: 50, backgroundImage: _displayProfileImage()),
                      Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(displayName))
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              selected: true,
              onTap: () {
                // This line code will close drawer programatically....
                Navigator.pop(context);
              },
            ),
            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('My Tasks'),
              onTap: () {
                // This line code will close drawer programatically....
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TasksScreen()));
              },
            ),
            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
            Divider(
              height: 2.0,
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Signout'),
              onTap: () {
                _signOut();
              },
            )
          ],
        ));
  }

  ImageProvider _displayProfileImage() {
    if (widget.worker != null && widget.worker.profileImage.isNotEmpty) {
      return new CachedNetworkImageProvider(widget.worker.profileImage);
    }

    return AssetImage('assets/images/logos/logo.png');
  }

  void _signOut() async {
    await widget.auth.signOut();
    await preferences.setHelperId(null).whenComplete(() {
      print('preference set to null');
      widget.onSignedOut();
    });
  }
}
