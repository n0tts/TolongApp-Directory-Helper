import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final VoidCallback onSearchResult;

  const SearchWidget({Key key, this.onSearchResult}) : super(key: key);
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController editingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new TextField(
      maxLines: 1,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search by name or place',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
      onSubmitted: onSubmitted,
      controller: editingController,
    );
  }

  onSubmitted(query) {}
}
