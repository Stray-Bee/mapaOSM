import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _service = LocationService();

  Position? _location;
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStream;

  Position? get location => _location;
  bool get isLoading => _isLoading;

  Future<void> fetchLocation() async {
    _isLoading = true;
    notifyListeners();

    _location = await _service.getCurrentPosition();
    _isLoading = false;
    notifyListeners();

    _startListening();
  }

  void _startListening() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _location = position;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
