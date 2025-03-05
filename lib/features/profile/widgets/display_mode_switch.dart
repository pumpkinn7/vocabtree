import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class DisplayModeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onToggle;

  const DisplayModeSwitch({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return BootstrapContainer(
      fluid: true,
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-12',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('การแสดงผลหน้าจอ', style: AppTextStyles.label),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 65,
                    child: DayNightSwitcher(
                      isDarkModeEnabled: isDarkMode,
                      onStateChanged: onToggle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
