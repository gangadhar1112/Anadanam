import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/annadaana_card.dart';
import '../../core/widgets/filter_chip_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/services/firestore_service.dart';
import '../upload/create_anadanam_screen.dart';
import '../anadanam/anadanam_details_screen.dart';
import '../anadanam/map_view_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/notifications_screen.dart';
import '../chat/chat_list_screen.dart';
import 'search_screen.dart';
import 'filter_bottom_sheet.dart';

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
              const Row(
                children: [
                  Text(
                    'Bengaluru',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16),
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

        // Filter out expired items client-side to handle real-time clock changes
        final activeDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['expireAt'] != null) {
            final expireAt = (data['expireAt'] as Timestamp).toDate();
            // Debug print to console to verify times
            debugPrint('Item: ${data['name']}, Expires: $expireAt, Now: $now');
            return expireAt.isAfter(now);
          }
          return false; // HIDE items that don't have the expireAt field (clean up old test data)
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
                return AnnaDaanCard(
                  title: data['name'] ?? 'No Name',
                  type: data['type'] ?? 'Community Food',
                  distance: '1.2 km away',
                  time: '${data['startTime']} – ${data['endTime']}',
                  food: data['foodDetails'] ?? '',
                  imageUrl: data['imageUrl'] ??
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
                  status: ServingStatus.servingNow,
                  isVerified: data['isVerified'] ?? false,
                  likes: data['likes'] ?? 0,
                  comments: data['comments'] ?? 0,
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
