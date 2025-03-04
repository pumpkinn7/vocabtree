import 'package:flutter/material.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';

class RegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const RegisterButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final buttonHeight = screenWidth > 600 ? 56.0 : 48.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Theme.of(context).colorScheme.surfaceVariant;
                  }
                  return Theme.of(context).colorScheme.surface;
                }),
              ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                )
              : Text(
                  'สมัครสมาชิก',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
        ),
      ),
    );
  }
}
