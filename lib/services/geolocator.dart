import 'package:TolongApp/models/worker.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  Future<List<Placemark>> getAddress(Position position) async {
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    return placemark;
  }

  Future<String> getCurrentAddress(Position position) async {
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String current = placemark.subLocality + ', ' + placemark.locality;
    return current.length > 0 ? current : 'Malaysia';
  }

  Future<Position> getCurrentPosition() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.latitude.toString() + ' ' + position.longitude.toString());
    return position;
  }

  Future<double> getDistance(Position from, Position to) async {
    double distanceInMeters = await Geolocator().distanceBetween(
        from.latitude, from.longitude, to.latitude, to.longitude);
    return distanceInMeters;
  }

  Future<List<Worker>> getMatchedDistance(
      Position position, List<Worker> workers, int distance) async {
    List<Worker> nearby = new List();

    for (var worker in workers) {
      Position workerPosition = new Position(
          latitude: worker.currentLocation.latitude,
          longitude: worker.currentLocation.longitude);

      double calculatedDistance =
          await this.getDistance(position, workerPosition);

      if (distance == 3 && calculatedDistance / 1000 <= distance) {
        nearby.add(worker);
      }

      if (distance == 5 &&
          calculatedDistance / 1000 > 3 &&
          calculatedDistance / 1000 <= distance) {
        nearby.add(worker);
      }

      if (distance == 10 &&
          calculatedDistance / 1000 > 5 &&
          calculatedDistance / 1000 <= distance) {
        nearby.add(worker);
      }
    }

    return nearby;
  }
}
