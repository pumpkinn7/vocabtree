// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';
import 'package:vocabtree/features/auth/services/email_verification_service.dart';
import 'package:vocabtree/features/auth/widgets/otp/otp_header.dart';
import 'package:vocabtree/features/auth/widgets/otp/otp_instructions.dart';
import 'package:vocabtree/features/auth/widgets/otp/resend_link.dart';
import 'package:vocabtree/features/auth/widgets/otp/verification_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;
  final File? profileImageFile;
  final User user;
  final String profileImageUrl;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.username,
    this.profileImageFile,
    required this.user,
    required this.profileImageUrl,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  User? user;
  late EmailVerificationService _verificationService;
  bool _isLoading = false; // เพิ่มตัวแปรสำหรับติดตามสถานะการโหลด

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _verificationService = EmailVerificationService(context);
  }

  Future<void> _handleVerifyEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _verificationService.verifyEmail(
        user!,
        widget.username,
        widget.email,
        widget.profileImageUrl,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendVerification() async {
    await _verificationService.resendVerificationEmail(user!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('ยืนยันการลงทะเบียน'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                  OtpHeader(
                    username: widget.username,
                    profileImageFile: widget.profileImageFile,
                  ),
                  SizedBox(
                      height: ResponsiveHelper.getVerticalSpacing(context)),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const OtpInstructions(),
                          SizedBox(
                              height:
                                  ResponsiveHelper.getVerticalSpacing(context) *
                                      0.5),
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.orange)
                              : VerificationButton(
                                  onPressed: _handleVerifyEmail,
                                  buttonText: 'ยืนยัน',
                                ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ResendLink(onResend: _handleResendVerification),
                    ),
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
