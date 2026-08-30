import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import 'location_selection_screen.dart';
import 'upload_provider.dart';

class CreateAnadanamScreen extends ConsumerStatefulWidget {
  const CreateAnadanamScreen({super.key});

  @override
  ConsumerState<CreateAnadanamScreen> createState() => _CreateAnadanamScreenState();
}

class _CreateAnadanamScreenState extends ConsumerState<CreateAnadanamScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 40, // Reduced quality for smaller Base64
        maxWidth: 600,   // Reduced width
      );
      if (image != null) {
        ref.read(anadanamFormProvider.notifier).updateImagePath(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(anadanamFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Anadanam'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help someone discover free food today.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            
            // Photo Section
            Text(
              'Add Photo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!, width: 1),
                image: formData.imagePath != null
                    ? DecorationImage(
                        image: FileImage(File(formData.imagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (formData.imagePath == null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt, size: 18),
                                label: const Text('Take Photo'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(130, 44),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.image, size: 18),
                                label: const Text('Gallery'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(130, 44),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (formData.imagePath != null)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Text(
              'Anadanam Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Anadanam Name',
                hintText: 'Enter name (e.g. Sri Sai Temple Anadanam)',
              ),
              onChanged: (val) => ref.read(anadanamFormProvider.notifier).updateName(val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: formData.type,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: ['Temple', 'NGO', 'Community', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(anadanamFormProvider.notifier).updateType(val);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _foodController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Food Details',
                hintText: 'What food is being served? (e.g. Rice, Sambar, Curd)',
              ),
              onChanged: (val) => ref.read(anadanamFormProvider.notifier).updateFoodDetails(val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Additional information...',
              ),
              onChanged: (val) => ref.read(anadanamFormProvider.notifier).updateDescription(val),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty || _foodController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter name and food details')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LocationSelectionScreen()),
                );
              },
              child: const Text('Next: Select Location'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
