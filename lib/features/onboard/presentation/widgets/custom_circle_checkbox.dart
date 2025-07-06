import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

class CustomCircleCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomCircleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 22.sp,
        height: 22.sp,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? AppColors.primaryColor : Colors.transparent,
          border: Border.all(
            color: value ? AppColors.primaryColor : AppColors.textHintColor,
            width: 3,
          ),
        ),
        child: value
            ? Center(
                child: Icon(
                  Icons.check,
                  size: 14.sp,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
} 