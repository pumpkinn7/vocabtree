import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

class SlideUpPanel extends StatefulWidget {
  final bool isCorrect;
  final String correctAnswer;
  final VoidCallback onNextPressed;

  const SlideUpPanel({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.onNextPressed,
  });

  @override
  State<SlideUpPanel> createState() => _SlideUpPanelState();
}

class _SlideUpPanelState extends State<SlideUpPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final FlutterTts flutterTts = FlutterTts();
  final translator = GoogleTranslator();
  String translatedWord = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
    _translateWord();
  }

  Future<void> _translateWord() async {
    try {
      final translation = await translator.translate(
        widget.correctAnswer,
        from: 'en',
        to: 'th',
      );
      setState(() {
        translatedWord = translation.text;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        translatedWord = 'ไม่สามารถแปลได้';
        isLoading = false;
      });
    }
  }

  Future<void> _speak() async {
    await flutterTts.speak(widget.correctAnswer);
  }

  Future<void> _openGoogleTranslate() async {
    final word = Uri.encodeComponent(widget.correctAnswer);
    // ลองใช้ URL แบบโมบายล์ก่อน
    var url = Uri.parse(
        'googletranslate://x-callback-url/translate?sl=en&tl=th&q=$word');

    try {
      final canOpenApp = await canLaunchUrl(url);
      if (canOpenApp) {
        await launchUrl(url);
        return;
      }

      // ถ้าเปิดแอพไม่ได้ ให้เปิดเว็บแทน
      url = Uri.parse('https://translate.google.com/?sl=en&tl=th&text=$word');
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // ถ้าเกิดข้อผิดพลาด ให้ลองเปิดใน browser mode
      url = Uri.parse('https://translate.google.com/?sl=en&tl=th&text=$word');
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
    }
  }

  Future<void> _openCambridgeDictionary() async {
    final word = Uri.encodeComponent(widget.correctAnswer);
    var url =
        Uri.parse('https://dictionary.cambridge.org/dictionary/english/$word');

    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // ถ้าเปิดในแอพภายนอกไม่ได้ ให้ลองเปิดใน webview
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.isCorrect ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(16), // มุมโค้งทั้งหมด
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          margin: const EdgeInsets.all(16), // เพิ่ม margin รอบด้าน
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ไอคอนและข้อความถูก/ผิด
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isCorrect ? Icons.check_circle : Icons.cancel,
                        color: widget.isCorrect
                            ? Colors.green[700]
                            : Colors.red[700],
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isCorrect ? 'ถูกต้อง!' : 'ไม่ถูกต้อง',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isCorrect
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // คำตอบที่ถูกต้องพร้อมปุ่มฟังเสียง
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'คำตอบที่ถูกต้อง:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        color: Colors.blue,
                        onPressed: _speak,
                      ),
                    ],
                  ),

                  // กล่องแสดงคำศัพท์
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.isCorrect
                            ? Colors.green[200]!
                            : Colors.red[200]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.correctAnswer,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLoading)
                          const CircularProgressIndicator()
                        else
                          Text(
                            translatedWord,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ปุ่มเครื่องมือช่วยเหลือ
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildToolButton(
                          'Google Translate',
                          Icons.translate,
                          _openGoogleTranslate,
                        ),
                        const SizedBox(width: 8),
                        _buildToolButton(
                          'Cambridge',
                          Icons.menu_book,
                          _openCambridgeDictionary,
                        ),
                      ],
                    ),
                  ),

                  // ปุ่มถัดไป
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'ถัดไป',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildToolButton(String label, IconData icon, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
