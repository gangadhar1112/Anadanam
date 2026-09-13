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
  ConsumerState<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  GoogleMapController? _mapController;

  final TextEditingController _searchController = TextEditingController();

  LatLng _center = const LatLng(12.9716, 77.5946);

  String _address = 'Fetching address...';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    if (_isLoading == false && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _address = 'Location service is disabled';
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _address = 'Location permission denied';
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _address = 'Location permission permanently denied';
        });
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();

      final newCenter = LatLng(
        position.latitude,
        position.longitude,
      );

      _center = newCenter;

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          newCenter,
          15,
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        await _updateAddressFromCoords(newCenter);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _address = 'Unable to get current location';
        });
      }
    }
  }

  Future<void> _updateAddressFromCoords(LatLng coords) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coords.latitude,
        coords.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final parts = <String>[
          if (p.name != null && p.name!.isNotEmpty) p.name!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
        ];

        final addr = parts.join(', ');

        if (mounted) {
          setState(() {
            _address = addr;
          });

          ref
              .read(anadanamFormProvider.notifier)
              .updateAddress(addr);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address =
          'Lat: ${coords.latitude.toStringAsFixed(4)}, '
              'Lng: ${coords.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  Future<void> _searchLocation(String query) async {
    // Don't allow search while loading
    if (_isLoading) return;

    if (query.trim().isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;

        final target = LatLng(
          loc.latitude,
          loc.longitude,
        );

        _center = target;

        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            target,
            16,
          ),
        );

        if (mounted) {
          setState(() {
            _center = target;
          });
        }

        await _updateAddressFromCoords(target);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location not found: $query',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _onCameraIdle() {
    // Don't update while initial location is loading
    if (_isLoading) return;

    ref
        .read(anadanamFormProvider.notifier)
        .updateLocation(
      _center.latitude,
      _center.longitude,
    );

    _updateAddressFromCoords(_center);
  }

  void _useThisLocation() {
    if (_isLoading) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecurringScheduleScreen(),
      ),
    );
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
              target: LatLng(
                formData.latitude,
                formData.longitude,
              ),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;

              if (!_isLoading) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    _center,
                    15,
                  ),
                );
              }
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Center marker
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(
                Icons.location_on,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          ),

          // Search
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Search for a location...',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // My Location button
          Positioned(
            right: 20,
            bottom: 230,
            child: FloatingActionButton(
              mini: true,
              backgroundColor:
              _isLoading ? Colors.grey.shade200 : Colors.white,
              onPressed: _isLoading ? null : _determinePosition,
              child: Icon(
                Icons.my_location,
                color: _isLoading
                    ? Colors.grey
                    : AppColors.primary,
              ),
            ),
          ),

          // Bottom location panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _address,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      // IMPORTANT:
                      // Disable button while location is loading
                      onPressed: _isLoading
                          ? null
                          : _useThisLocation,
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Use This Location',
                      ),
                    ),
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