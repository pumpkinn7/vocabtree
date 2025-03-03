import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final bool? obscureText;
  final VoidCallback? onTogglePassword;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.isPassword,
    this.obscureText,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? (obscureText ?? false) : false,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelText: label,
        labelStyle: AppTextStyles.inputText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText! ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: onTogglePassword,
              )
            : null,
      ),
    );
  }
}
