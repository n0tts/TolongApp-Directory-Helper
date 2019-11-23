import 'dart:async';

import 'package:TolongApp/bloc_provider.dart';
import 'package:geolocator/geolocator.dart';

class LocationBloc extends BlocBase {
  LocationBloc();

  final _locationController = StreamController<Position>.broadcast();
  Stream<Position> get getLocation => _locationController.stream;
  Sink<Position> get _setLocation => _locationController.sink;

  void getCurrentLocation() async {
    var options = new LocationOptions(
        accuracy: LocationAccuracy.best,
        distanceFilter: 100,
        timeInterval: 15000);
    Geolocator().getPositionStream(options).listen((position) {
      _setLocation.add(position);
    });
  }

  @override
  void dispose() {
    _locationController.close();
  }
}
