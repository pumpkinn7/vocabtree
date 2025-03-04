import 'package:flutter/material.dart';

class SuccessImage extends StatelessWidget {
  final double height;

  const SuccessImage({super.key, this.height = 150});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/Successmark.png',
      height: height,
    );
  }
}
