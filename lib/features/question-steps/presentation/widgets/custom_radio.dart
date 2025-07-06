import 'package:flutter/material.dart';

class CustomRadio extends StatelessWidget {
  final bool selected;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool enabled;

  const CustomRadio({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!selected) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? const Color(0xFF371382) : Colors.transparent,
              border: Border.all(
                color: selected ? const Color(0xFF371382) : const Color(0xFFC0C4D6),
                width: 2,
              ),
            ),
            child: selected
                ? const Center(
                    child: Icon(Icons.check, size: 18, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: enabled ? const Color(0xFF525871) : Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
} 