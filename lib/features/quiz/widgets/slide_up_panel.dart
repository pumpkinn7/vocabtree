import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class SlideUpPanel extends StatefulWidget {
  final bool isCorrect;
  final String correctAnswer;
  final VoidCallback onNextPressed;
  final String topic;

  const SlideUpPanel({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.onNextPressed,
    required this.topic,
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
  bool _isAddingToFlashcard = false;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resultColor =
        widget.isCorrect ? colorScheme.primary : colorScheme.error;
    final resultColorLight = widget.isCorrect
        ? colorScheme.primary.withOpacity(0.1)
        : colorScheme.error.withOpacity(0.1);

    return SafeArea(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: BootstrapContainer(
              fluid: true,
              padding: EdgeInsets.zero,
              children: [
                BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8 col-xl-6',
                      offsets:
                          'offset-xs-0 offset-sm-0 offset-md-1 offset-lg-2 offset-xl-3',
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // แสดงไอคอนและข้อความ ถูก/ผิด
                            _buildResultHeader(resultColor),

                            const SizedBox(height: 16),

                            // แสดงคำศัพท์และคำแปล
                            _buildWordCard(
                                colorScheme, resultColor, resultColorLight),

                            const SizedBox(height: 16),

                            // แสดงปุ่มเครื่องมือ
                            _buildToolButtons(colorScheme),

                            const SizedBox(height: 20),

                            // ปุ่มถัดไป
                            _buildNextButton(colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(Color resultColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: resultColor,
          size: 32,
        ),
        const SizedBox(width: 10),
        Text(
          widget.isCorrect ? 'ถูกต้อง!' : 'ไม่ถูกต้อง',
          style: AppTextStyles.headline.copyWith(
            color: resultColor,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildWordCard(
      ColorScheme colorScheme, Color resultColor, Color resultColorLight) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: resultColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'คำตอบที่ถูกต้อง:',
                  style: AppTextStyles.subtitle.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.volume_up_rounded,
                    color: colorScheme.primary,
                  ),
                  onPressed: _speak,
                  tooltip: 'ฟังเสียง',
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: resultColorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    widget.correctAnswer,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLoading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      translatedWord,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButtons(ColorScheme colorScheme) {
    return BootstrapRow(
      children: [
        BootstrapCol(
          sizes: 'col-4',
          child: _buildTool(
            'Google Translate',
            Icons.translate_rounded,
            _openGoogleTranslate,
            colorScheme.primary,
          ),
        ),
        BootstrapCol(
          sizes: 'col-4',
          child: _buildTool(
            'Cambridge',
            Icons.menu_book_rounded,
            _openCambridgeDictionary,
            colorScheme.secondary,
          ),
        ),
        BootstrapCol(
          sizes: 'col-4',
          child: _isAddingToFlashcard
              ? Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.tertiary,
                    ),
                  ),
                )
              : _buildTool(
                  'เพิ่มทบทวน',
                  Icons.bookmark_add_rounded,
                  _addToFlashcard,
                  colorScheme.tertiary,
                ),
        ),
      ],
    );
  }

  Widget _buildTool(
      String label, IconData icon, VoidCallback onPressed, Color color) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.onNextPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'ถัดไป',
          style: AppTextStyles.buttonText.copyWith(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _translateWord() async {
    if (!mounted) return;

    try {
      final translation = await translator.translate(
        widget.correctAnswer,
        from: 'en',
        to: 'th',
      );
      if (!mounted) return;
      setState(() {
        translatedWord = translation.text;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
    var url = Uri.parse(
        'googletranslate://x-callback-url/translate?sl=en&tl=th&q=$word');

    try {
      final canOpenApp = await canLaunchUrl(url);
      if (canOpenApp) {
        await launchUrl(url);
        return;
      }

      url = Uri.parse('https://translate.google.com/?sl=en&tl=th&text=$word');
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
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
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
    }
  }

  Future<void> _addToFlashcard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isAddingToFlashcard = true;
    });

    try {
      final wordDoc = await FirebaseFirestore.instance
          .collection('words')
          .where('mainWord', isEqualTo: widget.correctAnswer)
          .limit(1)
          .get();

      if (wordDoc.docs.isEmpty) return;

      final wordId = wordDoc.docs.first.id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vocabulary_progress')
          .doc(widget.topic)
          .set({
        'review_words': FieldValue.arrayUnion([wordId])
      }, SetOptions(merge: true));
    } catch (e) {
      // ไม่ต้องแสดง SnackBar เมื่อเกิดข้อผิดพลาด
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToFlashcard = false;
        });
      }
    }
  }
}
