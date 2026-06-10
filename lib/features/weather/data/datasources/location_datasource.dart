import 'package:geolocator/geolocator.dart';

abstract class LocationDataSource {
  Future<Position> getPosition();
}

class GeolocatorLocationDataSource implements LocationDataSource {
  @override
  Future<Position> getPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      throw Exception('Permission denied');
    }

    return Geolocator.getCurrentPosition();
  }
}
