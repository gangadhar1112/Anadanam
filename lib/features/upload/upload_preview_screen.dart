import 'dart:io';
import 'dart:convert';
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

  Future<String?> _imageToBase64(String path) async {
    try {
      final File file = File(path);
      final int sizeInBytes = await file.length();
      
      // If file is still too large (> 500KB), we might have issues
      if (sizeInBytes > 500000) {
        debugPrint('Warning: Image is large (${(sizeInBytes / 1024).toStringAsFixed(2)} KB)');
      }
      
      final List<int> bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting image to Base64: $e');
      return null;
    }
  }

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
      String imageUrl = formData.imageUrl;
      
      // Convert local image to Base64 if available
      if (formData.imagePath != null) {
        final base64String = await _imageToBase64(formData.imagePath!);
        if (base64String != null) {
          imageUrl = base64String;
        }
      }

      final dataToSave = formData.copyWith(imageUrl: imageUrl).toMap(user.uid);
      await ref.read(firestoreServiceProvider).addAnadanam(dataToSave);
      
      // Reset form
      ref.read(anadanamFormProvider.notifier).reset();
      
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: ${e.toString()}')),
        );
      }
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
              distance: 'Location Selected',
              time: '${formData.startTime} – ${formData.endTime}',
              food: formData.foodDetails,
              imageUrl: formData.imagePath != null ? null : formData.imageUrl,
              imageFile: formData.imagePath != null ? File(formData.imagePath!) : null,
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
            Text(formData.address.isEmpty ? 'Location selected on map' : formData.address),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Submit Anadanam'),
              ),
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
