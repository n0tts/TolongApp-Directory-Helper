import 'package:TolongApp/screens/category.dart';
import 'package:flutter/material.dart';

PreferredSize buildPreferredSize(BuildContext context, bool isAnonymous) {
  List<String> categories = [
    'Restaurant / Cafe',
    'Retail Shops',
    'Office Assistant',
    'Home Helper'
  ];
  List<String> categoryImages = [
    'assets/images/categories/icons8-restaurant-table-50.png',
    'assets/images/categories/icons8-store-50.png',
    'assets/images/categories/icons8-woman-profile-50.png',
    'assets/images/categories/icons8-housekeeping-50.png'
  ];

  return PreferredSize(
    preferredSize: Size(double.infinity, 120),
    child: Container(
      color: Color.fromARGB(255, 225, 109, 69),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(
            'BROWSE BY CATEGORY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
            textAlign: TextAlign.end,
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _categoryTabItem(
                  context, isAnonymous, categories[0], categoryImages[0]),
              _categoryTabItem(
                  context, isAnonymous, categories[1], categoryImages[1]),
              _categoryTabItem(
                  context, isAnonymous, categories[2], categoryImages[2]),
              _categoryTabItem(
                  context, isAnonymous, categories[3], categoryImages[3]),
            ],
          ),
          SizedBox(
            height: 8.0,
          )
        ],
      ),
    ),
  );
}

InkWell _categoryTabItem(
    BuildContext context, bool isAnonymous, String title, String asset) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CategoryScreen(
                  title: title,
                  isAnonymous: isAnonymous,
                )),
      );
    },
    child: Container(
      padding: EdgeInsets.all(5.0),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 4),
      child: Column(
        children: <Widget>[
          Image(
            image: AssetImage(asset),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
