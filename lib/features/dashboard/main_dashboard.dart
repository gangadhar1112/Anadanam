import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/annadaana_card.dart';
import '../../core/widgets/filter_chip_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/services/firestore_service.dart';
import '../upload/create_anadanam_screen.dart';

class MainDashboard extends ConsumerStatefulWidget {
  const MainDashboard({super.key});

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard> {
  int _currentIndex = 0;

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
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person_outline, color: AppColors.primary),
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
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Anadanam or location',
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          fillColor: Colors.grey[100],
          filled: true,
        ),
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
        onFilterSelected: (filter) {},
      ),
    );
  }

  Widget _buildFoodList() {
    return StreamBuilder<QuerySnapshot>(
      stream: ref.read(firestoreServiceProvider).streamActiveAnadanam(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Center(child: Text('No active Anadanam nearby.')),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ...docs.map((doc) {
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
            _buildNavItem(Icons.notifications_none, 'Alerts', 2),
            _buildNavItem(Icons.person_outline, 'Me', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
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
