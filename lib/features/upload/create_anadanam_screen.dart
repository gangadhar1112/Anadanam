import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
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
            
            // Photo Section (Placeholder)
            Text(
              'Add Photo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 44),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.image, size: 18),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(140, 44),
                        ),
                      ),
                    ],
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
