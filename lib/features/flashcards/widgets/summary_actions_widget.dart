import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import '../../../core/theme/text_styles.dart';

class SummaryActionsWidget extends StatelessWidget {
  final bool canAddToBank;
  final bool isAddingToBank;
  final VoidCallback onAddToBank;
  final VoidCallback onReset;

  const SummaryActionsWidget({
    super.key,
    required this.canAddToBank,
    required this.isAddingToBank,
    required this.onAddToBank,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BootstrapRow(
      children: [
        BootstrapCol(
          sizes: 'col-md-6 col-sm-12',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: canAddToBank ? onAddToBank : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.tertiary,
                foregroundColor: colorScheme.onTertiary,
                disabledBackgroundColor: colorScheme.surfaceVariant,
                disabledForegroundColor: colorScheme.onSurfaceVariant,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isAddingToBank
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onTertiary,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.add_to_photos_rounded,
                      color: colorScheme.onTertiary),
              label: Text(
                "เพิ่มเข้าคลังคำศัพท์",
                style: AppTextStyles.buttonText,
              ),
            ),
          ),
        ),
        BootstrapCol(
          sizes: 'col-md-6 col-sm-12',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, color: colorScheme.onError),
              label: Text(
                "รีเซ็ตทั้งหมด",
                style: AppTextStyles.buttonText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
