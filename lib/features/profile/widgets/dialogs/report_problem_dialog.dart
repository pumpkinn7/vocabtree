import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ReportProblemDialog extends StatefulWidget {
  final Function(String?, String, String) onSubmit;

  const ReportProblemDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<ReportProblemDialog> createState() => _ReportProblemDialogState();
}

class _ReportProblemDialogState extends State<ReportProblemDialog> {
  String? selectedProblem;
  final TextEditingController customProblemController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  final List<String> commonIssues = [
    'ข้อผิดพลาดในการทำแบบฝึกหัด',
    'การซิงค์ข้อมูลระหว่างอุปกรณ์',
    'ปัญหาเกี่ยวกับการเชื่อมต่ออินเทอร์เน็ต',
    'การแจ้งเตือนที่ไม่สม่ำเสมอ',
    'การอัปเดต และการดาวน์โหลดข้อมูล',
  ];

  @override
  void dispose() {
    customProblemController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('รายงานปัญหา', style: AppTextStyles.headline),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ปัญหาที่พบบ่อย:', style: AppTextStyles.label),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedProblem,
              hint: const Text('เลือกปัญหาที่พบ'),
              items: commonIssues.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedProblem = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: customProblemController,
              decoration: const InputDecoration(
                labelText: 'ปัญหาที่ฉันพบ',
                hintText: 'กรอกปัญหาที่คุณพบ',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: detailsController,
              decoration: const InputDecoration(
                labelText: 'รายละเอียด',
                hintText: 'กรอกรายละเอียดเพิ่มเติม',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('ยกเลิก'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('ส่งรายงาน'),
          onPressed: () {
            widget.onSubmit(
              selectedProblem,
              customProblemController.text,
              detailsController.text,
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
