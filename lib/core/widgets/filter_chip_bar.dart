import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FilterChipBar extends StatefulWidget {
  final List<String> filters;
  final Function(String) onFilterSelected;

  const FilterChipBar({
    super.key,
    required this.filters,
    required this.onFilterSelected,
  });

  @override
  State<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends State<FilterChipBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: widget.filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return ChoiceChip(
            label: Text(widget.filters[index]),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onFilterSelected(widget.filters[index]);
              }
            },
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
