import 'package:flutter/material.dart';

class BasicDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  BasicDialog({Key key, this.title, this.message, this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(title),
      content: new Text(message),
      actions: <Widget>[
        new FlatButton(
          child: new Text(buttonText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
