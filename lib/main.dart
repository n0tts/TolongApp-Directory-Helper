import 'package:TolongApp/bloc_provider.dart';
import 'package:TolongApp/blocs/helper_bloc.dart';
import 'package:TolongApp/screens/root.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(TolongApp());
}

class TolongApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        bloc: HelperBloc(),
        child: MaterialApp(
          title: 'TolongApp Helper',
          theme: ThemeData(
            primaryColor: Color.fromARGB(255, 225, 109, 69),
          ),
          home: RootPage(),
        ));
  }
}
