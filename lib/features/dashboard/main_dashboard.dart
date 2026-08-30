import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
import 'package:anadanaapp/features/chat/chat_detail_screen.dart';
import 'search_screen.dart';
import 'filter_bottom_sheet.dart';
import '../../core/providers/location_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/chat_service.dart';

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
    'foodType': 'All',
    'category': 'All',
  };

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
                    ref.watch(locationProvider).currentAddress,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
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
          'Breakfast',
          'Lunch',
          'Dinner',
          'Temple',
          'NGO',
          'Community',
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
            foodType: _activeFilters['foodType'],
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
          
          // 1. Check Expiration
          if (data['expireAt'] != null) {
            final expireAt = (data['expireAt'] as Timestamp).toDate();
            if (expireAt.isBefore(now)) return false;
          } else {
            return false; // Hide items without expireAt (old data)
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
          final knownTypes = ['Temple', 'NGO', 'Community', 'Other'];
          if (knownTypes.contains(category)) {
            return data['type'] == category;
          }

          // Handle Meal Time Filters
          final startTimeStr = data['startTime'] as String? ?? '';
          final endTimeStr = data['endTime'] as String? ?? '';
          
          DateTime? parseTime(String timeStr, DateTime date) {
            try {
              final formats = [
                DateFormat.jm(), // "12:00 PM"
                DateFormat('h:mm a'), 
                DateFormat('HH:mm'), 
                DateFormat('H:mm'), 
              ];
              
              for (var f in formats) {
                try {
                  final parsed = f.parse(timeStr.trim());
                  return DateTime(date.year, date.month, date.day, parsed.hour, parsed.minute);
                } catch (_) {}
              }
              return null;
            } catch (_) {
              return null;
            }
          }

          if (category == 'Serving Now') {
            final isRecurring = data['isRecurring'] as bool? ?? false;
            final expireAt = (data['expireAt'] as Timestamp).toDate();
            
            // Check if it's even for today (expireAt is the end of the next session)
            // If it's tomorrow, it can't be "Serving Now" today.
            if (expireAt.day != now.day || expireAt.month != now.month || expireAt.year != now.year) {
              return false; 
            }

            final startTime = parseTime(startTimeStr, now);
            final endTime = parseTime(endTimeStr, now);
            if (startTime == null || endTime == null) return false;
            
            return now.isAfter(startTime) && now.isBefore(endTime);
          }

          // Breakfast (5 AM - 11 AM), Lunch (11 AM - 4 PM), Dinner (4 PM - 11 PM)
          final startTime = parseTime(startTimeStr, now);
          if (startTime != null) {
            if (category == 'Breakfast') return startTime.hour >= 5 && startTime.hour < 11;
            if (category == 'Lunch') return startTime.hour >= 11 && startTime.hour < 16;
            if (category == 'Dinner') return startTime.hour >= 16 && startTime.hour < 23;
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
                          'foodType': 'All',
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

                return AnnaDaanCard(
                  title: data['name'] ?? 'No Name',
                  type: data['type'] ?? 'Community Food',
                  distance: distance,
                  time: '${data['startTime']} – ${data['endTime']}',
                  food: data['foodDetails'] ?? '',
                  imageUrl: data['imageUrl'] ??
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
                  status: ServingStatus.servingNow,
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
                  onChatTap: () async {
                    final otherUserId = data['userId'];
                    final otherUserName = data['name'] ?? 'Provider';
                    if (otherUserId == null) return;
                    if (currentUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please login to chat.')),
                      );
                      return;
                    }

                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final chatId = await ref.read(chatServiceProvider).getOrCreateChat(otherUserId, otherUserName);
                      if (context.mounted) {
                        Navigator.pop(context); // Close loading
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              chatId: chatId,
                              otherUserName: otherUserName,
                              otherUserId: otherUserId,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  onTap: () {
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
