import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class CustomDateBox extends StatelessWidget {
  final String hint;
  final String value;
  final int maxLength;
  final ValueChanged<String> onChanged;

  const CustomDateBox({
    super.key,
    required this.hint,
    required this.value,
    required this.maxLength,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: hint == 'YYYY' ? 90 : 60,
      height: 48,
      child: Center(
        child: TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textHintColor,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              height: 1.0,
            ),
            counterText: '',
            filled: true,
            fillColor: AppColors.whiteColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.textHintColor,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
            ),
          ),
          style: const TextStyle(
            color: AppColors.primeTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.0,
          ),
          keyboardType: TextInputType.number,
          maxLength: maxLength,
          onChanged: onChanged,
        ),
      ),
    );
  }
} 