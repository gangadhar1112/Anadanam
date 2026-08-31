import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../core/providers/location_provider.dart';
import '../../core/widgets/status_badge.dart';
import 'anadanam_details_screen.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng _initialPosition = const LatLng(17.3850, 78.4867); // Default: Hyderabad
  Map<String, Marker> _markers = {};
  Map<String, dynamic>? _selectedAnadanam;
  bool _isLoadingLocation = true;
  BitmapDescriptor? _templeIcon;
  BitmapDescriptor? _otherIcon;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadIcons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIcons() async {
    _templeIcon = await _getMarkerIcon('Temple');
    _otherIcon = await _getMarkerIcon('Other');
    if (mounted) setState(() {});
  }

  Future<ui.Image> _createIcon(Color color, IconData icon) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const size = ui.Size(140, 160);

    // 1. Draw Outer Halo (Glow effect)
    final haloPaint = Paint()
      ..color = color.withAlpha(40)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(70, 50), 65, haloPaint);
    
    final haloBorderPaint = Paint()
      ..color = color.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(const Offset(70, 50), 65, haloBorderPaint);

    // 2. Draw Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    Path shadowPath = Path();
    shadowPath.addOval(const Rect.fromLTWH(30, 130, 80, 20));
    canvas.drawPath(shadowPath, shadowPaint);

    // 3. Draw Pin Shape (Teardrop)
    final Paint pinPaint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final Path pinPath = Path();
    pinPath.moveTo(70, 140);
    pinPath.cubicTo(35, 95, 25, 75, 25, 50);
    pinPath.arcTo(Rect.fromLTWH(25, 5, 90, 90), 3.14, 3.14, false);
    pinPath.cubicTo(115, 75, 105, 95, 70, 140);
    pinPath.close();

    canvas.drawPath(pinPath, pinPaint);
    canvas.drawPath(pinPath, borderPaint);

    // 4. Draw Inner Highlight Circle
    final Paint innerCirclePaint = Paint()..color = Colors.white.withAlpha(60);
    canvas.drawCircle(const Offset(70, 50), 36, innerCirclePaint);

    // 5. Draw Icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 48,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(70 - (textPainter.width / 2), 50 - (textPainter.height / 2)),
    );

    final picture = pictureRecorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  Future<BitmapDescriptor> _getMarkerIcon(String type) async {
    final color = type == 'Temple' ? AppColors.primary : AppColors.secondary;
    final iconData = type == 'Temple' ? Icons.temple_hindu : Icons.restaurant;
    
    final image = await _createIcon(color, iconData);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_initialPosition, 14),
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    try {
      // Close keyboard
      FocusScope.of(context).unfocus();
      
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final target = LatLng(loc.latitude, loc.longitude);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(target, 15),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not find "$query"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _calculateDistance(double? lat, double? lng) {
    return ref.read(locationProvider.notifier).calculateDistance(lat, lng);
  }

  void _onMarkerTapped(Map<String, dynamic> data) {
    setState(() {
      _selectedAnadanam = data;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(data['latitude'] as double, data['longitude'] as double),
        15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeAnadanamStream = ref.watch(firestoreServiceProvider).streamActiveAnadanam();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: activeAnadanamStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _markers = {};
                final now = DateTime.now();
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;
                  
                  // Filter out expired items
                  if (data['expireAt'] != null) {
                    final expireAt = (data['expireAt'] as Timestamp).toDate();
                    if (expireAt.isBefore(now)) continue;
                  } else {
                    continue; // Skip items without expireAt
                  }

                  final lat = data['latitude'] as double?;
                  final lng = data['longitude'] as double?;
                  
                  if (lat != null && lng != null) {
                    final type = data['type'] as String? ?? 'Other';
                    final marker = Marker(
                      markerId: MarkerId(doc.id),
                      position: LatLng(lat, lng),
                      onTap: () => _onMarkerTapped(data),
                      icon: type == 'Temple' 
                          ? (_templeIcon ?? BitmapDescriptor.defaultMarker)
                          : (_otherIcon ?? BitmapDescriptor.defaultMarker),
                    );
                    _markers[doc.id] = marker;
                  }
                }
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 14,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: Set<Marker>.of(_markers.values),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onTap: (_) {
                  setState(() {
                    _selectedAnadanam = null;
                  });
                  FocusScope.of(context).unfocus();
                },
              );
            },
          ),
          
          if (_isLoadingLocation)
            const Center(child: CircularProgressIndicator()),

          // Top Search Bar
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
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
                        hintText: 'Search location or Anadanam',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.primary),
                    onPressed: () {
                      // Show filters
                    },
                  ),
                ],
              ),
            ),
          ),

          // My Location Button
          Positioned(
            right: 20,
            bottom: _selectedAnadanam == null ? 100 : 250,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // Selected Marker Bottom Preview
          if (_selectedAnadanam != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildAnadanamPreview(_selectedAnadanam!),
            ),
        ],
      ),
    );
  }

  Widget _buildAnadanamPreview(Map<String, dynamic> data) {
    final distance = _calculateDistance(data['latitude'], data['longitude']);
    
    return Dismissible(
      key: Key(data['id']),
      direction: DismissDirection.down,
      onDismissed: (_) {
        setState(() {
          _selectedAnadanam = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Hero(
                  tag: 'anadanam_${data['id']}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildPreviewImage(data['imageUrl']),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(
                        status: StatusBadge.calculate(
                          data['startTime'] as String? ?? '',
                          data['endTime'] as String? ?? '',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['name'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (distance.isNotEmpty)
                            Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['startTime']} - ${data['endTime']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final status = StatusBadge.calculate(
                                  data['startTime'] as String? ?? '',
                                  data['endTime'] as String? ?? '',
                                );
                                
                                if (status == ServingStatus.ended) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('This Anadanam session has ended.'),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnadanamDetailsScreen(data: data),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('View'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final lat = data['latitude'] as double?;
                                final lng = data['longitude'] as double?;
                                if (lat == null || lng == null) return;
                                final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.navigation, size: 16),
                              label: const Text(
                                'Directions',
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage(String? imageUrl) {
    const String placeholder = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&q=80';
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.network(placeholder, width: 100, height: 100, fit: BoxFit.cover);
    }

    if (imageUrl.startsWith('data:image') || !imageUrl.startsWith('http')) {
      try {
        final String base64Str = imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
        return Image.memory(
          base64Decode(base64Str),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.network(placeholder, width: 100, height: 100, fit: BoxFit.cover),
        );
      } catch (e) {
        return Image.network(placeholder, width: 100, height: 100, fit: BoxFit.cover);
      }
    }

    return Image.network(
      imageUrl,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.network(placeholder, width: 100, height: 100, fit: BoxFit.cover),
    );
  }
}

