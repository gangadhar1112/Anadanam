import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'upload_preview_screen.dart';
import 'upload_provider.dart';

class RecurringScheduleScreen extends ConsumerStatefulWidget {
  const RecurringScheduleScreen({super.key});

  @override
  ConsumerState<RecurringScheduleScreen> createState() => _RecurringScheduleScreenState();
}

class _RecurringScheduleScreenState extends ConsumerState<RecurringScheduleScreen> {
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final formData = ref.read(anadanamFormProvider);
    final initialTime = isStart ? formData.startTime : formData.endTime;
    
    // Parse existing time string to TimeOfDay
    TimeOfDay initialTimeOfDay;
    try {
      final format = DateFormat.jm(); // "12:00 PM"
      final date = format.parse(initialTime);
      initialTimeOfDay = TimeOfDay.fromDateTime(date);
    } catch (e) {
      initialTimeOfDay = isStart ? const TimeOfDay(hour: 12, minute: 0) : const TimeOfDay(hour: 14, minute: 0);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTimeOfDay,
    );

    if (picked != null) {
      final formattedTime = picked.format(context);
      if (isStart) {
        ref.read(anadanamFormProvider.notifier).updateTime(formattedTime, formData.endTime);
      } else {
        ref.read(anadanamFormProvider.notifier).updateTime(formData.startTime, formattedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(anadanamFormProvider);

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
              groupValue: formData.isRecurring,
              onChanged: (val) => ref.read(anadanamFormProvider.notifier).updateIsRecurring(val!),
              activeColor: AppColors.primary,
            ),
            RadioListTile<bool>(
              title: const Text('Recurring'),
              value: true,
              groupValue: formData.isRecurring,
              onChanged: (val) => ref.read(anadanamFormProvider.notifier).updateIsRecurring(val!),
              activeColor: AppColors.primary,
            ),
            
            if (formData.isRecurring) ...[
              const SizedBox(height: 24),
              const Text('Select serving days', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: List.generate(_days.length, (index) {
                  final day = _days[index];
                  final isSelected = formData.recurringDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (val) {
                      final updatedDays = List<String>.from(formData.recurringDays);
                      if (val) {
                        updatedDays.add(day);
                      } else {
                        updatedDays.remove(day);
                      }
                      ref.read(anadanamFormProvider.notifier).updateDays(updatedDays);
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.charcoal,
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
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: _TimePickerField(label: 'Start Time', time: formData.startTime),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: _TimePickerField(label: 'End Time', time: formData.endTime),
                  ),
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
