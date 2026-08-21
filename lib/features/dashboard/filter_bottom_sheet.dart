import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFilterChips(['1 km', '3 km', '5 km', '10 km'], '3 km'),
          const SizedBox(height: 24),
          const Text('Food Type', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFilterChips(['Breakfast', 'Lunch', 'Dinner'], 'Lunch'),
          const SizedBox(height: 24),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFilterChips(['Temple', 'NGO', 'Community', 'Gurudwara'], 'All'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply Filters'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChips(List<String> labels, String selected) {
    return Wrap(
      spacing: 8,
      children: labels.map((label) {
        final isSelected = label == selected;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (val) {},
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
