import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../anadanam/anadanam_details_screen.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    // Automatically trigger cleanup of expired posts when Admin Console is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firestoreService.cleanupExpiredPosts();
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'All Posts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Tab
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.streamPendingAnadanam(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                return _buildList(context, ref, docs, isPending: true);
              },
            ),
            // All Posts Tab
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.streamAllAnadanam(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                return _buildList(context, ref, docs, isPending: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<QueryDocumentSnapshot> docs,
      {required bool isPending}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPending) _buildStats(context, docs.length),
          const SizedBox(height: 16),
          Text(
            isPending ? 'Pending Submissions' : 'All Anadanam Posts',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          if (docs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(isPending ? 'No pending submissions' : 'No posts found'),
              ),
            )
          else
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildListItem(context, ref, data, doc.id, isPending: isPending);
            }),
        ],
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context, WidgetRef ref, Map<String, dynamic> data, String id,
      {required bool isPending}) {
    final title = data['name'] ?? 'Untitled';
    final userName = data['userName'] ?? 'Anonymous';
    final status = data['status'] ?? 'pending';
    final imageUrl = data['imageUrl'] ??
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&q=80';
    final timestamp = data['createdAt'] as Timestamp?;
    final dateStr = timestamp != null
        ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
        : 'Unknown time';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (!isPending)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: status == 'approved'
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: status == 'approved' ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Submitted by: $userName', style: const TextStyle(fontSize: 12)),
                      Text(dateStr,
                          style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                if (isPending) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleDelete(context, ref, id, title),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleApprove(context, ref, id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDelete(context, ref, id, title),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete Post'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  onPressed: () {
                    final Map<String, dynamic> detailData = Map.from(data);
                    detailData['id'] = id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnadanamDetailsScreen(data: detailData),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, int pendingCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Pending', pendingCount.toString(), AppColors.warning),
        _buildStatCard('Active Today', '124', AppColors.success),
        _buildStatCard('Reported', '3', AppColors.error),
        _buildStatCard('Total Users', '1.2k', AppColors.primary),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(firestoreServiceProvider).updateAnadanamStatus(id, 'approved');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post approved successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving post: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Anadanam?'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(firestoreServiceProvider).deleteAnadanam(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting post: $e')),
          );
        }
      }
    }
  }
}
