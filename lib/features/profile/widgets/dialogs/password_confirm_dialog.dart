import 'package:flutter/material.dart';

class PasswordConfirmDialog extends StatefulWidget {
  final Function(String) onConfirm;

  const PasswordConfirmDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<PasswordConfirmDialog> createState() => _PasswordConfirmDialogState();
}

class _PasswordConfirmDialogState extends State<PasswordConfirmDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ยืนยันรหัสผ่าน'),
      content: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'กรุณากรอกรหัสผ่านของคุณ',
        ),
      ),
      actions: [
        TextButton(
          child: const Text('ยกเลิก'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('ยืนยัน'),
          onPressed: () {
            widget.onConfirm(_passwordController.text);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
