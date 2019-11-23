import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int rating;

  final bool alignCenter;
  const RatingWidget({
    Key key,
    @required this.rating, this.alignCenter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = new List();
    for (var i = 0; i < rating; i++) {
      widgets.add(Icon(
        Icons.star,
        color: Colors.orange,
        size: 16.0,
      ));
    }

    if (rating != 5) {
      int extra = 5 - rating;
      for (var i = 0; i < extra; i++) {
        widgets.add(Icon(
          Icons.star,
          color: Colors.black54,
          size: 16.0,
        ));
      }
    }

    return Row(
      mainAxisAlignment: alignCenter? MainAxisAlignment.center : MainAxisAlignment.start,
      children: widgets,
    );
  }
}
