import 'package:flutter/material.dart';

class NewsCategoryChip extends StatelessWidget {
  const NewsCategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF626B80),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        selectedColor: theme.colorScheme.secondary,
        backgroundColor: const Color(0xFFF0F1F5),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}
