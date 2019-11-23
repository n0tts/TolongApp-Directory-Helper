import 'package:TolongApp/models/worker.dart';
import 'package:TolongApp/screens/helper_details.dart';
import 'package:TolongApp/utils/list_utils.dart';
import 'package:TolongApp/widgets/rating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget helperCard(BuildContext context, Worker item, bool hasPermission) {
  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Access Denied"),
          content: new Text(
              "Only registered user is allowed to view helper details."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  return InkWell(
      onTap: () {
        hasPermission
            ? _navigateToDetailScreen(context, item)
            : _showVerifyEmailDialog();
      },
      child: Padding(
          padding: EdgeInsets.only(left: 16.0, top: 10.0, right: 16.0),
          child: new Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0)),
                            image: DecorationImage(
                                image: AssetImage(item.profileImage),
                                fit: BoxFit.cover)),
                      )),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(ListUtils.parseListToString(
                                    item.jobPosition)),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  item.firstName + ' ' + item.lastName,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                RatingWidget(
                                  rating: item.rating,
                                  alignCenter: false,
                                ),
                                SizedBox(
                                  height: 15.0,
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Location'),
                                        Text(
                                            item.address[0].toUpperCase() +
                                                item.address.substring(1),
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w600))
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: <Widget>[
                                      new BuildAvailabilityView(
                                        isAvailable: item.availability,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.attach_money,
                                            size: 16.0,
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Flexible(
                                            child: Text('8.00/Hr'),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(height: 2.0, color: Colors.grey),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 10.0, 16.0, 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.calendar,
                                    size: 20.0, color: Colors.blue),
                                Icon(FontAwesomeIcons.userTag,
                                    size: 20.0, color: Colors.green),
                                Icon(
                                  FontAwesomeIcons.solidHeart,
                                  size: 20.0,
                                  color: Colors.red,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )));
}

void _navigateToDetailScreen(BuildContext context, Worker item) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => HelperDetailScreen(
              worker: item,
            )),
  );
}

class BuildAvailabilityView extends StatelessWidget {
  final bool isAvailable;
  const BuildAvailabilityView({
    Key key,
    this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isAvailable ? new IsAvailableWidget() : new NotAvailableWidget();
  }
}

class IsAvailableWidget extends StatelessWidget {
  const IsAvailableWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.green,
        ),
        SizedBox(
          width: 5.0,
        ),
        Flexible(
          child: Column(
            children: <Widget>[Text('Available Today')],
          ),
        )
      ],
    );
  }
}

class NotAvailableWidget extends StatelessWidget {
  const NotAvailableWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          FontAwesomeIcons.solidCircle,
          size: 16,
          color: Colors.red,
        ),
        SizedBox(
          width: 5.0,
        ),
        Flexible(
          child: Column(
            children: <Widget>[Text('Not Available')],
          ),
        )
      ],
    );
  }
}
