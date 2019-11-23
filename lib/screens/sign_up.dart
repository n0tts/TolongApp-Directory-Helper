import 'package:TolongApp/blocs/helper_bloc.dart';
import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/services/authentication.dart';
import 'package:TolongApp/services/workers.dart';
import 'package:TolongApp/widgets/basic_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  final BaseAuth auth;

  const SignUpPage({Key key, this.auth}) : super(key: key);
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _bloc = HelperBloc();
  WorkerService workerService = new WorkerService();
  final _formKey = new GlobalKey<FormState>();
  String _email;
  String _firstName;
  String _lastName;
  String _password;
  bool _isLoading = false;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _showError(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BasicDialog(
          title: "Unable to sign up",
          message: error,
          buttonText: 'Try Again',
        );
      },
    );
  }

  void _showSuccess() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BasicDialog(
          title: "Sign Up Completed",
          message: "You can now sign in using the information provided earlier",
          buttonText: 'OK',
        );
      },
    );
  }

  void _validateAndSubmit() async {
    setState(() {
      _isLoading = true;
    });
    if (_validateAndSave()) {
      authenticateAndAddHelper();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void authenticateAndAddHelper() async {
    try {
      await widget.auth.signUp(_email, _password, _firstName + ' ' + _lastName);
      FirebaseUser user = await widget.auth.getCurrentUser();
      Worker worker = new Worker(_firstName, _lastName, user.email, user.uid);
      await _bloc.addHelper(workerService.autoFillRandomProperties(worker));
      _showSuccess();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _showCircularProgress() {
    if (!_isLoading) {
      return SizedBox();
    }
    return Center(
        child: CircularProgressIndicator(
      backgroundColor: Colors.green,
    ));
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Email',
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
      onSaved: (value) => _email = value,
    );

    final firstName = TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'First Name',
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value.isEmpty ? 'Please enter first name' : null,
      onSaved: (value) => _firstName = value,
    );

    final lastName = TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Last Name',
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value.isEmpty ? 'Please enter last name' : null,
      onSaved: (value) => _lastName = value,
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
      validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
      onSaved: (value) => _password = value,
    );

    final signUpButton = Container(
      width: double.infinity,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onPressed: _validateAndSubmit,
        padding: EdgeInsets.all(12),
        color: Color.fromARGB(255, 106, 187, 67),
        child: Text('SIGNUP', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
        backgroundColor: Color.fromARGB(255, 225, 109, 69),
        body: Stack(
          children: <Widget>[
            _buildSignUpForm(
                firstName, lastName, email, password, signUpButton),
            _showCircularProgress()
          ],
        ));
  }

  Form _buildSignUpForm(TextFormField firstName, TextFormField lastName,
      TextFormField email, TextFormField password, Container signUpButton) {
    return Form(
      key: _formKey,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 50, right: 50),
              child: Column(
                children: <Widget>[
                  Hero(
                    tag: 'hero',
                    child: CircleAvatar(
                        radius: 80,
                        child: Image(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/images/logos/logo.png'),
                        )),
                  ),
                  SizedBox(height: 30.0),
                  firstName,
                  SizedBox(height: 15.0),
                  lastName,
                  SizedBox(height: 15.0),
                  email,
                  SizedBox(height: 15.0),
                  password,
                  SizedBox(height: 24.0),
                  signUpButton,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
