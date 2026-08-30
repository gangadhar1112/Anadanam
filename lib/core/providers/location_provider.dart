import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationState {
  final LatLng? currentLatLng;
  final String currentAddress;
  final bool isLoading;

  LocationState({
    this.currentLatLng,
    this.currentAddress = 'Fetching...',
    this.isLoading = false,
  });

  LocationState copyWith({
    LatLng? currentLatLng,
    String? currentAddress,
    bool? isLoading,
  }) {
    return LocationState(
      currentLatLng: currentLatLng ?? this.currentLatLng,
      currentAddress: currentAddress ?? this.currentAddress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState()) {
    updateLocation();
  }

  Future<void> updateLocation() async {
    state = state.copyWith(isLoading: true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(isLoading: false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(isLoading: false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(isLoading: false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng latLng = LatLng(position.latitude, position.longitude);
      
      String address = 'Unknown Location';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = '${p.subLocality ?? p.name}, ${p.locality}';
        }
      } catch (_) {}

      state = LocationState(
        currentLatLng: latLng,
        currentAddress: address,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  String calculateDistance(double? targetLat, double? targetLng) {
    if (state.currentLatLng == null || targetLat == null || targetLng == null) {
      return '1.2 km away'; // Default fallback
    }
    
    double distanceInMeters = Geolocator.distanceBetween(
      state.currentLatLng!.latitude,
      state.currentLatLng!.longitude,
      targetLat,
      targetLng,
    );

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m away';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km away';
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
