import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../anadanam/anadanam_details_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final TextEditingController _postSearchController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger cleanup of expired posts when Admin Console is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(firestoreServiceProvider).cleanupExpiredPosts();
    });
  }

  @override
  void dispose() {
    _postSearchController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console'),
          actions: [
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: 'Cleanup Expired Posts',
              onPressed: () async {
                await firestoreService.cleanupExpiredPosts();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cleanup completed.')),
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.restaurant_menu), text: 'All Posts'),
              Tab(icon: Icon(Icons.people_outline), text: 'Registered Users'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Top Analytics Overview Dashboard Cards
            _buildAnalyticsHeader(firestoreService),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPostsTab(firestoreService),
                  _buildUsersTab(firestoreService),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REAL-TIME ANALYTICS HEADER
  // ---------------------------------------------------------------------------

  Widget _buildAnalyticsHeader(FirestoreService firestoreService) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Live Platform Metrics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                    SizedBox(width: 6),
                    Text(
                      'Live Sync',
                      style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Total Users Metric
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.streamAllUsers(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildMetricCard(
                      label: 'Registered Users',
                      value: count.toString(),
                      icon: Icons.people,
                      color: AppColors.primary,
                      isLoading: snapshot.connectionState == ConnectionState.waiting,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Total Posts Metric (Preserved lifetime count)
              Expanded(
                child: StreamBuilder<int>(
                  stream: firestoreService.streamLifetimePostsCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return _buildMetricCard(
                      label: 'Total Posts',
                      value: count.toString(),
                      icon: Icons.restaurant,
                      color: Colors.purple,
                      isLoading: snapshot.connectionState == ConnectionState.waiting,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Posted Today Metric
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.streamTodayPosts(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildMetricCard(
                      label: 'Posted Today',
                      value: count.toString(),
                      icon: Icons.today,
                      color: AppColors.success,
                      isLoading: snapshot.connectionState == ConnectionState.waiting,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Posted Last 7 Days Metric
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.streamPastDaysPosts(7),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildMetricCard(
                      label: 'Last 7 Days',
                      value: count.toString(),
                      icon: Icons.date_range,
                      color: Colors.orange,
                      isLoading: snapshot.connectionState == ConnectionState.waiting,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // POSTS TAB
  // ---------------------------------------------------------------------------

  Widget _buildPostsTab(FirestoreService firestoreService) {
    return Column(
      children: [
        // Search Bar & Heading
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _postSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by post title or food details...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.today, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    "Today's Posts",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Posts List Stream
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.streamAllAnadanam(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              final searchQuery = _postSearchController.text.trim().toLowerCase();
              final now = DateTime.now();
              final startOfToday = DateTime(now.year, now.month, now.day);

              final filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final food = (data['foodDetails'] ?? '').toString().toLowerCase();

                // 1. Text Search Filter
                if (searchQuery.isNotEmpty && !name.contains(searchQuery) && !food.contains(searchQuery)) {
                  return false;
                }

                // 2. Today's Post Filter
                if (data['createdAt'] != null) {
                  final timestamp = data['createdAt'] as Timestamp?;
                  if (timestamp != null && timestamp.toDate().isBefore(startOfToday)) {
                    return false;
                  }
                }

                return true;
              }).toList();

              if (filteredDocs.isEmpty) {
                return const Center(
                  child: Text('No posts match your filters.', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildPostCard(context, ref, data, doc.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(BuildContext context, WidgetRef ref, Map<String, dynamic> data, String postId) {
    final title = data['name'] ?? 'Untitled';
    final userName = data['userName'] ?? 'Anonymous';
    final status = data['status'] ?? 'approved';
    final food = data['foodDetails'] ?? 'Food details';
    final timestamp = data['createdAt'] as Timestamp?;
    final dateStr = timestamp != null
        ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
        : 'Unknown date';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text('By: $userName • $dateStr', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('🍴 Food: $food', style: const TextStyle(fontSize: 13)),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _handleDeletePost(context, ref, postId, title),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    final Map<String, dynamic> detailData = Map.from(data);
                    detailData['id'] = postId;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnadanamDetailsScreen(data: detailData),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REGISTERED USERS TAB
  // ---------------------------------------------------------------------------

  Widget _buildUsersTab(FirestoreService firestoreService) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _userSearchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search registered users by name or email...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              fillColor: Colors.grey[100],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.streamAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              final searchQuery = _userSearchController.text.trim().toLowerCase();

              final filteredUsers = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['displayName'] ?? '').toString().toLowerCase();
                final email = (data['email'] ?? '').toString().toLowerCase();

                if (searchQuery.isNotEmpty && !name.contains(searchQuery) && !email.contains(searchQuery)) {
                  return false;
                }
                return true;
              }).toList();

              if (filteredUsers.isEmpty) {
                return const Center(
                  child: Text('No registered users found.', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final doc = filteredUsers[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['displayName'] ?? 'User';
                  final email = data['email'] ?? 'No Email';
                  final photoUrl = data['photoUrl'];
                  final isGuest = data['isGuest'] ?? false;
                  final createdAt = data['createdAt'] as Timestamp?;
                  final dateStr = createdAt != null
                      ? DateFormat('MMM d, yyyy').format(createdAt.toDate())
                      : 'Unknown date';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: photoUrl != null && photoUrl.toString().isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null || photoUrl.toString().isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$email\nJoined: $dateStr', style: const TextStyle(fontSize: 12)),
                      isThreeLine: true,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGuest ? Colors.orange.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isGuest ? 'Guest' : 'Registered',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isGuest ? Colors.orange : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  Future<void> _handleDeletePost(BuildContext context, WidgetRef ref, String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post?'),
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
