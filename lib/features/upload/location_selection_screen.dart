import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme/app_colors.dart';
import 'recurring_schedule_screen.dart';
import 'upload_provider.dart';

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  ConsumerState<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends ConsumerState<LocationSelectionScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng _center = const LatLng(12.9716, 77.5946); // Default Bengaluru
  String _address = 'Fetching address...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      _center = LatLng(position.latitude, position.longitude);
      
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_center, 15),
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        _updateAddressFromCoords(_center);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddressFromCoords(LatLng coords) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coords.latitude,
        coords.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addr = '${p.name}, ${p.subLocality}, ${p.locality}';
        setState(() {
          _address = addr;
        });
        ref.read(anadanamFormProvider.notifier).updateAddress(addr);
      }
    } catch (e) {
      setState(() {
        _address = 'Lat: ${coords.latitude.toStringAsFixed(4)}, Lng: ${coords.longitude.toStringAsFixed(4)}';
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final target = LatLng(loc.latitude, loc.longitude);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(target, 16),
        );
        setState(() {
          _center = target;
        });
        _updateAddressFromCoords(target);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not found: $query')),
        );
      }
    }
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _onCameraIdle() {
    ref.read(anadanamFormProvider.notifier).updateLocation(_center.latitude, _center.longitude);
    _updateAddressFromCoords(_center);
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(anadanamFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(formData.latitude, formData.longitude),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (!_isLoading) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_center, 15),
                );
              }
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          
          // Center Marker
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on, size: 50, color: AppColors.primary),
            ),
          ),
          
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textHint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search for a location...',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            right: 20,
            bottom: 230,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _address,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecurringScheduleScreen()),
                      );
                    },
                    child: const Text('Use This Location'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
