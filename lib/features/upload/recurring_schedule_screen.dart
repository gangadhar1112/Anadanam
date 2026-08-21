import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'upload_preview_screen.dart';

class RecurringScheduleScreen extends StatefulWidget {
  const RecurringScheduleScreen({super.key});

  @override
  State<RecurringScheduleScreen> createState() => _RecurringScheduleScreenState();
}

class _RecurringScheduleScreenState extends State<RecurringScheduleScreen> {
  bool _isRecurring = false;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<bool> _selectedDays = List.generate(7, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serving Schedule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How often is food served?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            
            RadioListTile<bool>(
              title: const Text('One Time'),
              value: false,
              groupValue: _isRecurring,
              onChanged: (val) => setState(() => _isRecurring = val!),
              activeColor: AppColors.primary,
            ),
            RadioListTile<bool>(
              title: const Text('Recurring'),
              value: true,
              groupValue: _isRecurring,
              onChanged: (val) => setState(() => _isRecurring = val!),
              activeColor: AppColors.primary,
            ),
            
            if (_isRecurring) ...[
              const SizedBox(height: 24),
              const Text('Select serving days', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: List.generate(_days.length, (index) {
                  return FilterChip(
                    label: Text(_days[index]),
                    selected: _selectedDays[index],
                    onSelected: (val) => setState(() => _selectedDays[index] = val),
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedDays[index] ? Colors.white : AppColors.charcoal,
                    ),
                  );
                }),
              ),
            ],
            
            const SizedBox(height: 32),
            const Text('Serving Time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TimePickerField(label: 'Start Time', time: '12:00 PM'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TimePickerField(label: 'End Time', time: '02:00 PM'),
                ),
              ],
            ),
            
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadPreviewScreen()),
                );
              },
              child: const Text('Next: Review'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final String time;

  const _TimePickerField({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Icon(Icons.access_time, size: 18, color: AppColors.textHint),
            ],
          ),
        ),
      ],
    );
  }
}
