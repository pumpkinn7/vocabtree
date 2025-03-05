import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/profile/models/profile_model.dart';

class ProfileInfo extends StatelessWidget {
  final ProfileModel profile;

  const ProfileInfo({
    super.key,
    required this.profile,
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
              child: Column(
                children: [
                  _buildInfoField(
                      'ชื่อผู้ใช้งาน', profile.username ?? 'ไม่พบข้อมูล'),
                  const SizedBox(height: 10),
                  _buildInfoField('อีเมลของฉัน', profile.getMaskedEmail()),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 23, top: 5),
          child: Text(label, style: AppTextStyles.label),
        ),
        Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.inputText),
          ),
        ),
      ],
    );
  }
}
