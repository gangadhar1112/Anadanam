import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, String> initialFilters;

  const FilterBottomSheet({
    super.key,
    this.initialFilters = const {
      'distance': '3 km',
      'foodType': 'All',
      'category': 'All',
    },
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedDistance;
  late String _selectedFoodType;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedDistance = widget.initialFilters['distance'] ?? '3 km';
    _selectedFoodType = widget.initialFilters['foodType'] ?? 'All';
    _selectedCategory = widget.initialFilters['category'] ?? 'All';
  }

  void _resetFilters() {
    setState(() {
      _selectedDistance = '3 km';
      _selectedFoodType = 'All';
      _selectedCategory = 'All';
    });
  }

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
                onPressed: _resetFilters,
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFilterChips(
            ['1 km', '3 km', '5 km', '10 km'],
            _selectedDistance,
            (val) => setState(() => _selectedDistance = val),
          ),
          const SizedBox(height: 24),
          const Text('Food Type', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFilterChips(
            ['All', 'Breakfast', 'Lunch', 'Dinner'],
            _selectedFoodType,
            (val) => setState(() => _selectedFoodType = val),
          ),
          const SizedBox(height: 24),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFilterChips(
            ['All', 'Temple', 'NGO', 'Community', 'Gurudwara'],
            _selectedCategory,
            (val) => setState(() => _selectedCategory = val),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'distance': _selectedDistance,
                  'foodType': _selectedFoodType,
                  'category': _selectedCategory,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChips(List<String> labels, String selected, Function(String) onSelected) {
    return Wrap(
      spacing: 8,
      children: labels.map((label) {
        final isSelected = label == selected;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (val) {
            if (val) onSelected(label);
          },
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
