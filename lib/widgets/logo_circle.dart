import 'package:flutter/material.dart';

class LogoCircle extends StatefulWidget {
  final double radius;

  LogoCircle({Key key, this.radius}) : super(key: key);

  _LogoCircleState createState() => _LogoCircleState();
}

class _LogoCircleState extends State<LogoCircle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Hero(
        tag: 'hero',
        child: CircleAvatar(
            radius: widget.radius,
            child: Image(
              fit: BoxFit.contain,
              image: AssetImage('assets/images/logos/logo.png'),
            )),
      ),
    );
  }
}
