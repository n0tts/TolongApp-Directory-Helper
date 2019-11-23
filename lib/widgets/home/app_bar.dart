import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget {
  final String displayName;

  CustomAppBar({Key key, this.displayName}) : super(key: key);

  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  List<Tab> tabs;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    setState(() {
      tabs = <Tab>[
        Tab(text: 'Edit Profile'),
        Tab(text: 'Add Schedule'),
        Tab(text: 'View Earnings'),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return new AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
            child: Image(
          fit: BoxFit.contain,
          image: AssetImage('assets/images/logos/logo.png'),
        )),
      ),
      title: Text(widget.displayName ?? 'Welcome'),
      actions: <Widget>[
        IconButton(
            onPressed: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ))
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: tabs,
      ),
    );
  }
}
