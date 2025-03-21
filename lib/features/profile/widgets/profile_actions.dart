import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import '../widgets/notification_dot.dart';

class ProfileActions extends StatelessWidget {
  final VoidCallback onEditFriends;
  final VoidCallback onManageAccount;
  final VoidCallback onSignOut;
  final bool showFriendRequestNotification;

  const ProfileActions({
    super.key,
    required this.onEditFriends,
    required this.onManageAccount,
    required this.onSignOut,
    this.showFriendRequestNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return BootstrapContainer(
      fluid: true,
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-6',
              child: _buildButton(
                'แก้ไขเพื่อน',
                onPressed: onEditFriends,
                showNotification: showFriendRequestNotification,
              ),
            ),
            BootstrapCol(
              sizes: 'col-6',
              child: _buildButton('จัดการบัญชี', onPressed: onManageAccount),
            ),
          ],
        ),
        const SizedBox(height: 70),
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-12',
              child: Center(
                child: TextButton(
                  onPressed: onSignOut,
                  child: Text(
                    'ออกจากระบบ',
                    style: AppTextStyles.label.copyWith(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(
    String label, {
    required VoidCallback onPressed,
    bool showNotification = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.inputText),
          if (showNotification)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: NotificationDot(
                showDot: true,
                size: 8,
              ),
            ),
        ],
      ),
    );
  }
}
