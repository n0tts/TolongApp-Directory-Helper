import 'dart:io';

import 'package:TolongApp/blocs/helper_bloc.dart';
import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/screens/edit_profile.dart';
import 'package:TolongApp/services/uploader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final Worker worker;
  final DocumentSnapshot snapshot;
  ProfileScreen({Key key, this.worker, this.snapshot}) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UploaderService uploader = new UploaderService();
  final _bloc = HelperBloc();
  String _errorMessage;
  String _networkPath;

  Future getResume() async {
    var path = await FilePicker.getFilePath(
        type: FileType.CUSTOM, fileExtension: 'PDF');
    var file = new File(path);
    var filename = path.split('/').last;
    final StorageReference ref = storage
        .ref()
        .child('helper')
        .child(widget.worker.reference)
        .child('resume')
        .child(filename);
    uploader.uploadFile(file, ref).then((file) {
      _showSuccess();
    }).catchError((onError) {
      setState(() {
        _errorMessage = onError;
      });
      _showError();
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _networkPath = 'assets/images/logos/logo.png';
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  ImageProvider _displayProfileImage() {
    if (widget.worker != null && widget.worker.profileImage.isNotEmpty) {
      return new CachedNetworkImageProvider(widget.worker.profileImage);
    }
    return AssetImage(_networkPath);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 25, left: 8.0, right: 8.0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 100,
              backgroundImage: _displayProfileImage(),
            ),
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    widget.worker.displayName,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.worker.email,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () {
                        getResume();
                      },
                      padding: EdgeInsets.all(12),
                      color: Color.fromARGB(255, 106, 187, 67),
                      child: Text('Upload latest resume',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                    reference: widget.worker.reference,
                                    snapshot: widget.snapshot)));
                      },
                      padding: EdgeInsets.all(12),
                      color: Color.fromARGB(255, 106, 187, 67),
                      child: Text('Edit profile',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Upload Resume Error"),
          content: new Text(_errorMessage),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Try Again"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Upload Resume"),
          content: new Text('Your resume is now saved into our system'),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
