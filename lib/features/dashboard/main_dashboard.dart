import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/annadaana_card.dart';
import '../../core/widgets/filter_chip_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/services/firestore_service.dart';
import 'package:anadanaapp/features/upload/create_anadanam_screen.dart';
import 'package:anadanaapp/features/anadanam/anadanam_details_screen.dart';
import 'package:anadanaapp/features/anadanam/map_view_screen.dart';
import 'package:anadanaapp/features/profile/profile_screen.dart';
import 'package:anadanaapp/features/profile/notifications_screen.dart';
import 'package:anadanaapp/features/chat/chat_list_screen.dart';
import '../anadanam/comments_section.dart';
import 'search_screen.dart';
import 'filter_bottom_sheet.dart';
import '../../core/providers/location_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';

class MainDashboard extends ConsumerStatefulWidget {
  const MainDashboard({super.key});

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  Map<String, String> _activeFilters = {
    'distance': '3 km',
    'category': 'All',
  };

  String _getDisplayName(String address) {
    if (address.isEmpty || address == 'Fetching...') return 'Fetching...';
    final parts = address.split(',');
    final name = parts.first.trim();
    if (name.isEmpty && parts.length > 1) {
      return parts[1].trim(); // Fallback to locality if sub-locality is empty
    }
    return name.isEmpty ? 'Unknown' : name;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(initialFilters: _activeFilters),
    );

    if (result != null) {
      setState(() {
        _activeFilters = result;
        _selectedCategory = result['category']!;
      });
    }
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MapViewScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;

    // Use ref.listen to start notifications only when user changes or app starts
    // rather than every time the build method runs.
    ref.listen(authServiceProvider, (previous, next) {
      if (next.currentUser != null) {
        ref.read(notificationServiceProvider).startListeningToUserNotifications(next.currentUser!.uid);
      }
    });

    // Also start once if user is already logged in and listener not active
    // This handles the first build case.
    if (user != null) {
      ref.read(notificationServiceProvider).startListeningToUserNotifications(user.uid);
    }

    // Sync user location to Firestore for nearby notifications
    ref.listen(locationProvider, (previous, next) {
      if (user != null && next.currentLatLng != null) {
        ref.read(firestoreServiceProvider).updateUserLocation(
          user.uid,
          next.currentLatLng!.latitude,
          next.currentLatLng!.longitude,
        );
      }
    });

    // Force an initial location update if not already synced
    if (user != null) {
      final loc = ref.read(locationProvider);
      if (loc.currentLatLng != null) {
        ref.read(firestoreServiceProvider).updateUserLocation(
          user.uid,
          loc.currentLatLng!.latitude,
          loc.currentLatLng!.longitude,
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    _buildSearchBar(),
                    _buildFilters(),
                    _buildFoodList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateAnadanamScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Location',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Row(
                children: [
                  Text(
                    _getDisplayName(ref.watch(locationProvider).currentAddress),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
          ),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person_outline, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Free Food Serving Today',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find Anadanam near you',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: IgnorePointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Anadanam or location',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: AppColors.primary),
              onPressed: _showFilterBottomSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FilterChipBar(
        filters: const [
          'All',
          'Near Me',
          'Serving Now',
          'Temple',
          'NGO',
          'Community',
          'Others',
        ],
        selectedFilter: _selectedCategory,
        onFilterSelected: (filter) {
          setState(() {
            _selectedCategory = filter;
            _activeFilters['category'] = filter;
          });
        },
      ),
    );
  }

  Widget _buildFoodList() {
    return StreamBuilder<QuerySnapshot>(
      stream: ref.watch(firestoreServiceProvider).streamActiveAnadanam(
            category: _activeFilters['category'],
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var docs = snapshot.data?.docs ?? [];
        final now = DateTime.now();
        final currentUserId = ref.watch(authServiceProvider).currentUser?.uid;

        // Filter out expired items and apply advanced category filters client-side
        final activeDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          
        // 1. Check Expiration (CRITICAL RULE: Hide immediately if time is up)
        if (data['expireAt'] != null) {
          final expireAt = (data['expireAt'] as Timestamp).toDate();
          if (expireAt.isBefore(now)) {
            print('DEBUG: Hiding expired post: ${data['name']}');
            return false;
          }
        } else {
          return false; // Hide items without expireAt
        }

          // 2. Apply Category Filters (Client-side for complex ones)
          final category = _activeFilters['category'];
          if (category == null || category == 'All') return true;

          // Handle "Near Me" Filter (Within 3 km as requested)
          if (category == 'Near Me') {
            final lat = data['latitude'] as double?;
            final lng = data['longitude'] as double?;
            if (lat == null || lng == null) return false;
            
            final currentLatLng = ref.read(locationProvider).currentLatLng;
            if (currentLatLng == null) return true; // Show all if location not ready

            final distance = Geolocator.distanceBetween(
              currentLatLng.latitude,
              currentLatLng.longitude,
              lat,
              lng,
            );
            return distance <= 3000; // 3km threshold
          }

          // Handle known types
          final knownTypes = ['Temple', 'NGO', 'Community', 'Other', 'Others'];
          if (knownTypes.contains(category)) {
            final targetType = category == 'Others' ? 'Other' : category;
            return data['type'] == targetType;
          }

          // Handle Meal Time Filters
          final startTimeStr = data['startTime'] as String? ?? '';
          final endTimeStr = data['endTime'] as String? ?? '';
          
          // Handle "Serving Now" Filter
          if (category == 'Serving Now') {
            final status = StatusBadge.calculate(startTimeStr, endTimeStr);
            return status == ServingStatus.servingNow;
          }

          return true;
        }).toList();

        if (activeDocs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No Anadanam found matching your criteria.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _activeFilters = {
                          'distance': '3 km',
                          'category': 'All',
                        };
                        _selectedCategory = 'All';
                      });
                    },
                    child: const Text('Clear all filters'),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ...activeDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                final distance = ref.read(locationProvider.notifier).calculateDistance(
                      data['latitude'] as double?,
                      data['longitude'] as double?,
                    );
                final List likedBy = data['likedBy'] ?? [];
                final isLiked = currentUserId != null && likedBy.contains(currentUserId);

                final status = StatusBadge.calculate(
                  data['startTime'] as String? ?? '',
                  data['endTime'] as String? ?? '',
                );

                return AnnaDaanCard(
                  postId: doc.id,
                  title: data['name'] ?? 'No Name',
                  type: data['type'] ?? 'Community Food',
                  distance: distance,
                  time: '${data['startTime']} – ${data['endTime']}',
                  food: data['foodDetails'] ?? '',
                  latitude: data['latitude'] as double?,
                  longitude: data['longitude'] as double?,
                  imageUrl: data['imageUrl'] ??
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
                  status: status,
                  isVerified: data['isVerified'] ?? false,
                  likes: data['likes'] ?? 0,
                  isLiked: isLiked,
                  comments: data['comments'] ?? 0,
                  onLikeTap: () {
                    if (currentUserId != null) {
                      ref.read(firestoreServiceProvider).toggleLike(doc.id, currentUserId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please login to like.')),
                      );
                    }
                  },
                  onChatTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.75,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        expand: false,
                        builder: (context, scrollController) => CommentsSection(
                          postId: doc.id,
                          scrollController: scrollController,
                        ),
                      ),
                    );
                  },
                  onTap: () {
                    if (status == ServingStatus.ended) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This Anadanam session has ended for today.'),
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
                );
              }),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      notchMargin: 8.0,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.map_outlined, 'Map', 1),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(Icons.chat_bubble_outline, 'Chat', 2),
            _buildNavItem(Icons.person_outline, 'Me', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textHint,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
