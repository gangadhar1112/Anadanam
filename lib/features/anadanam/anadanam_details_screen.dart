import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_badge.dart';

class AnadanamDetailsScreen extends StatelessWidget {
  const AnadanamDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: _buildContent(context),
              ),
            ],
          ),
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.charcoal),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Sri Sai Anadanam',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: Colors.blue, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Temple Anadanam',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const StatusBadge(status: ServingStatus.servingNow),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 18, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                '12:00 PM – 2:00 PM',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                '1.2 km away',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const Divider(height: 40),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Free vegetarian lunch served to everyone daily. We welcome all community members to join us for a nutritious meal prepared with love and service.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Food Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildFoodItem('🍚 Rice'),
          _buildFoodItem('🥣 Sambar'),
          _buildFoodItem('🥛 Curd'),
          _buildFoodItem('🍬 Sweet'),
          const SizedBox(height: 24),
          Text(
            'Location',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Sri Sai Temple, Whitefield, Bengaluru, Karnataka 560066',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('Map Preview Implementation'),
            ),
          ),
          const SizedBox(height: 100), // Space for bottom action
        ],
      ),
    );
  }

  Widget _buildFoodItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('GET DIRECTIONS'),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
