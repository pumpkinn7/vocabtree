import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // เพิ่มระยะห่างด้านบน
              const Align(
                alignment: Alignment.topRight,
                child: Text(
                  'รายงานปัญหา',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50, // เปลี่ยนขนาดรูปโปรไฟล์
                      backgroundImage: AssetImage(
                          'assets/icons/profile_icon.png'), // เปลี่ยนรูปภาพโปรไฟล์
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mr. Johnweeds',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'เข้าร่วมเมื่อ: วันที่ 23 กันยายน 2566',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextFieldContainer('ชื่อ', 'Mr. Johnweeds'),
              const SizedBox(height: 8),
              _buildTextFieldContainer('อีเมล', 'stewi.22@gmail.com'),
              const SizedBox(height: 8),
              _buildTextFieldContainer('รหัสผ่าน', '**********'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('การแสดงผลหน้าจอ'),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 70, // กำหนดความกว้าง
                    child: DayNightSwitcher(
                      isDarkModeEnabled: false,
                      onStateChanged: (isDarkModeEnabled) {
                        // Handle switch state
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets/images/friend_edit.png',
                      width: MediaQuery.of(context).size.width *
                          0.4, // ปรับขนาดรูปภาพให้ responsive
                      height: 80,
                    ),
                    Image.asset(
                      'assets/images/profile_edit.png',
                      width: MediaQuery.of(context).size.width *
                          0.4, // ปรับขนาดรูปภาพให้ responsive
                      height: 80,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'ออกจากระบบ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldContainer(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity, // ทำให้เต็มความกว้างของหน้าจอ
          height: 50, // กำหนดความสูงให้เท่ากัน
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
