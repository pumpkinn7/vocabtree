import 'package:flutter/material.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';
import 'package:vocabtree/features/auth/widgets/account_success/success_content.dart';

class AccountSuccessScreen extends StatelessWidget {
  const AccountSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: ResponsiveHelper.getContentWidth(context),
              child: Column(
                children: [
                  SizedBox(
                      height: ResponsiveHelper.getVerticalSpacing(context)),
                  SuccessContent(
                    onLoginPressed: () =>
                        Navigator.pushNamed(context, '/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
