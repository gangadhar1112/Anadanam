import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  LatLng _center = const LatLng(12.9716, 77.5946); // Default Bengaluru
  String _address = 'Fetching address...';

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _onCameraIdle() {
    // In a real app, use geocoding here
    // For now, update coordinates and use a mock address
    ref.read(anadanamFormProvider.notifier).updateLocation(_center.latitude, _center.longitude);
    
    // Simulating address fetch
    setState(() {
      _address = 'Lat: ${_center.latitude.toStringAsFixed(4)}, Lng: ${_center.longitude.toStringAsFixed(4)}';
    });
    ref.read(anadanamFormProvider.notifier).updateAddress(_address);
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
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          
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
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.textHint),
                  SizedBox(width: 12),
                  Text('Search for a location...', style: TextStyle(color: AppColors.textHint)),
                ],
              ),
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
