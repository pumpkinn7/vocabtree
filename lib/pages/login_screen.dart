import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/tree_6977580.png',
                height: 150,
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'ชื่อผู้ใช้งาน หรืออีเมล',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'รหัสผ่าน',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[700],
                      ),
                      onPressed: _toggleObscureText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text.rich(
                  TextSpan(
                    text: 'ลืมรหัสผ่าน?',
                    style: const TextStyle(color: Colors.teal, fontSize: 14),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, '/reset-password');
                      },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // ฟังก์ชันเมื่อกด "เข้าสู่ระบบ"
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  text: 'ไม่มีบัญชีผู้ใช้งานใช่หรือไม่? ',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'สมัครเลย',
                      style: const TextStyle(color: Colors.teal, fontSize: 14),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/register');
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
