import 'package:flutter/material.dart';

class SnackbarWidget extends StatelessWidget {
  SnackbarWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        // Validate will return true if the form is valid, or false if
        // the form is invalid.

        // If the form is valid, we want to show a Snackbar
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Processing Data')));
      },
      child: Text('Save'),
    );
  }
}
