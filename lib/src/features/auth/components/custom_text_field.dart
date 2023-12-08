import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_layout.dart';
import '../../../config/app_text.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    required this.controller,
    this.isPassword = false,
    required this.hint,
    required this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  bool isPassword;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      obscureText: widget.isPassword,
      autocorrect: false,
      clipBehavior: Clip.antiAlias,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: AppLayout.borderRadiusSmall,
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppLayout.borderRadiusSmall,
          borderSide: const BorderSide(
            width: 2,
            color: AppColors.primaryColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppLayout.borderRadiusSmall,
          borderSide: BorderSide(
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
        ),
        hintText: widget.hint,
        hintStyle: AppText.textStyleHint,
      ),
    );
  }
}
