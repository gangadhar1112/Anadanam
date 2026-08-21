import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MyAnadanamScreen extends StatelessWidget {
  const MyAnadanamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Anadanam'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Pending'),
              Tab(text: 'Past'),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, 'Active'),
            _buildList(context, 'Pending'),
            _buildList(context, 'Past'),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, String status) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 2,
      itemBuilder: (context, index) {
        return _buildItem(context, status);
      },
    );
  }

  Widget _buildItem(BuildContext context, String status) {
    Color statusColor;
    switch (status) {
      case 'Active':
        statusColor = AppColors.success;
        break;
      case 'Pending':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.textHint;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&q=80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sri Sai Anadanam',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text('Aug 21, 2026 • 12:00 PM'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
