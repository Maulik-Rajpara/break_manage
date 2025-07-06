import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool enabled;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 23.sp,
            height: 23.sp,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF371382) : Colors.transparent,
              border: Border.all(
                color: value ? const Color(0xFF371382) : const Color(0xFFC0C4D6),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: value
                ? const Center(
                    child: Icon(Icons.check, size: 18, color: Colors.white),
                  )
                : null,
          ),
           SizedBox(width: 8.sp),
          Text(
            label,
            style: TextStyle(
              color: enabled ? const Color(0xFF525871) : Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
} 