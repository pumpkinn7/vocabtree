import 'package:flutter/material.dart';

class ProfilePageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const ProfilePageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 8,
          width: currentPage == index ? 24 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: currentPage == index
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
