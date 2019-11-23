import 'package:TolongApp/blocs/helper_bloc.dart';
import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/services/authentication.dart';
import 'package:TolongApp/services/geolocator.dart';
import 'package:TolongApp/services/uploader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  final String reference;
  final DocumentSnapshot snapshot;
  EditProfileScreen({
    Key key,
    this.reference,
    this.snapshot,
  }) : super(key: key);

  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _bloc = HelperBloc();
  final _formKey = GlobalKey<FormState>();
  GeolocatorService geoService = new GeolocatorService();
  Auth authService = new Auth();
  UploaderService uploader = new UploaderService();

  Worker worker;
  String _errorMessage;
  GeoPoint _currentLocation;
  String _networkPath;
  String _selectedCategory;
  List<String> _categories;
  List<String> _selectedPositions;
  Map<String, List<String>> positions;

  TextEditingController firstNameController = TextEditingController(text: "");
  TextEditingController lastNameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  TextEditingController mobileController = TextEditingController(text: "");

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var filename = image.path.split('/').last;
    final StorageReference ref = storage
        .ref()
        .child('helper')
        .child(widget.reference)
        .child('profile')
        .child(filename);
    uploader.uploadFile(image, ref).then((file) {
      print('fetching network image ' + file.isSuccessful.toString());
      file.events.listen((event) {
        switch (event.type) {
          case StorageTaskEventType.success:
            uploader.getDownloadUrl(ref).then((url) {
              setState(() {
                worker.profileImageField = filename;
                _networkPath = url;
                print(_networkPath);
              });
            });
            break;
          case StorageTaskEventType.progress:
            print('uploader in progress');
            break;
          default:
        }
      });
    }).catchError((onError) {
      setState(() {
        _errorMessage = onError;
      });
      _showError();
    }).whenComplete(() {
      print('upload operation completed');
    });
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
    });
    if (_validateAndSave()) {
      worker.firstNameField = firstNameController.text;
      worker.lastNameField = lastNameController.text;
      worker.emailField = emailController.text;
      worker.addressField = addressController.text;
      worker.mobileField = mobileController.text;
      worker.currentLocationField = _currentLocation;
      worker.profileImageField = _networkPath;
      worker.categoryField = _selectedCategory;
      worker.jobPositionField = _selectedPositions;
      bool isUpdated = await _bloc.updateHelper(widget.snapshot, worker);
      isUpdated
          ? _showSuccess()
          : () {
              setState(() {
                _errorMessage = 'Unable to update profile';
              });
              _showError();
            };
    } else {
      setState(() {
        _errorMessage =
            "There's something wrong with your information. Make sure all information is provided";
      });
      _showError();
    }
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Unable to save profile"),
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
          title: new Text("Profile update"),
          content: new Text('Your profile is now saved into our system'),
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

  void _fetchNetworkImage() {
    if (worker.profileImage != null && worker.profileImage.isNotEmpty) {
      setState(() {
        _networkPath = worker.profileImage;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _networkPath = '';
    });
    if (widget.snapshot.exists) {
      setState(() {
        worker = Worker.fromSnapshot(widget.snapshot);
        firstNameController.text = worker.firstName;
        lastNameController.text = worker.lastName;
        emailController.text = worker.email;
        mobileController.text = worker.mobileNo;
        addressController.text = worker.address;
        _categories = ['retail shops', 'restaurant / cafe', 'office assistant'];
        _selectedCategory =
            worker.category.isNotEmpty ? worker.category : _categories[1];
        _selectedPositions =
            worker.jobPosition.isNotEmpty ? worker.jobPosition : [];
        positions = new Map();
        positions.putIfAbsent(
            'restaurant / cafe',
            () => [
                  'Barista',
                  'Cook - Chinese food',
                  'Cook - Western food',
                  'Waiter / Waitress'
                ]);
        positions.putIfAbsent(
            'retail shops', () => ['Cashier', 'Manager', 'Helper']);
        positions.putIfAbsent(
            'office assistant', () => ['Manager', 'Assistant', 'Staff']);
      });

      _fetchNetworkImage();

      geoService.getCurrentPosition().then((currentPosition) {
        setState(() {
          _currentLocation =
              new GeoPoint(currentPosition.latitude, currentPosition.longitude);
          worker.currentLocationField = _currentLocation;
        });

        if (worker.address.isEmpty || worker.address == null) {
          print('setting address based on geolocation');
          geoService.getAddress(currentPosition).then((addresses) {
            for (var placemark in addresses) {
              setState(() {
                worker.addressField =
                    "${placemark.name}, ${placemark.thoroughfare}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
                addressController.text = worker.address;
              });
              break;
            }
          });
        }
      });
    }
  }

  List<Widget> _buildPositionList() {
    List<String> skills = positions.putIfAbsent(_selectedCategory, () {});
    List<Widget> tiles = [];
    skills.forEach((skill) => {
          tiles.add(new CheckboxListTile(
            onChanged: (bool value) {
              setState(() {
                value
                    ? _selectedPositions.add(skill)
                    : _selectedPositions.remove(skill);
              });
            },
            value: _selectedPositions.contains(skill),
            title: Text(skill),
          ))
        });

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: worker != null
                  ? Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: _networkPath != null &&
                                    _networkPath.isNotEmpty
                                ? new CachedNetworkImageProvider(_networkPath)
                                : AssetImage('assets/images/logos/logo.png'),
                          ),
                        ),
                        TextFormField(
                          controller: firstNameController,
                          decoration: const InputDecoration(
                            hintText: '',
                            labelText: 'First Name',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                          },
                        ),
                        TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            hintText: '',
                            labelText: 'Last Name',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                          },
                        ),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            enabled: false,
                            hintText: '',
                            labelText: 'Email',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                          },
                        ),
                        TextFormField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '',
                            labelText: 'Mobile No',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                          },
                        ),
                        TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            hintText: '',
                            labelText: 'Address',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                          },
                        ),
                        Row(
                          children: <Widget>[
                            Text('Category'),
                            SizedBox(
                              width: 16.0,
                            ),
                            Center(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                onChanged: (String newValue) {
                                  setState(() {
                                    _selectedPositions.clear();
                                    _selectedCategory = newValue;
                                  });
                                },
                                items: _categories
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        ListView(
                          shrinkWrap: true,
                          children: _buildPositionList(),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onPressed: () {
                                _validateAndSubmit();
                              },
                              padding: EdgeInsets.all(12),
                              color: Color.fromARGB(255, 106, 187, 67),
                              child: Text('Save',
                                  style: TextStyle(color: Colors.white)),
                            )),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ));
  }
}
