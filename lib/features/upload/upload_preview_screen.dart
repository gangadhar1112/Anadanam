import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/annadaana_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import 'upload_provider.dart';
import 'success_screen.dart';

class UploadPreviewScreen extends ConsumerStatefulWidget {
  const UploadPreviewScreen({super.key});

  @override
  ConsumerState<UploadPreviewScreen> createState() => _UploadPreviewScreenState();
}

class _UploadPreviewScreenState extends ConsumerState<UploadPreviewScreen> {
  bool _isSubmitting = false;

  void _submit() async {
    setState(() => _isSubmitting = true);

    final formData = ref.read(anadanamFormProvider);
    final user = ref.read(authServiceProvider).currentUser;

    if (user == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit.')),
      );
      return;
    }

    try {
      await ref.read(firestoreServiceProvider).addAnadanam(formData.toMap(user.uid));
      
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(anadanamFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This is how your Anadanam will look to others.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            AnnaDaanCard(
              title: formData.name,
              type: formData.type,
              distance: '1.2 km away',
              time: '${formData.startTime} – ${formData.endTime}',
              food: formData.foodDetails,
              imageUrl: formData.imageUrl,
              status: ServingStatus.today,
              likes: 0,
              comments: 0,
            ),
            const SizedBox(height: 32),
            const Text(
              'Location Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text('Whitefield, Bengaluru'), // Mock address
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Anadanam'),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Edit Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
