import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class DailyVocabularyCard extends StatefulWidget {
  const DailyVocabularyCard({super.key});
  @override
  State<DailyVocabularyCard> createState() => _DailyVocabularyCardState();
}

class _DailyVocabularyCardState extends State<DailyVocabularyCard> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isLoading = true;
  String _word = '';
  String _partOfSpeech = '';
  String _definition = '';

  @override
  void initState() {
    super.initState();
    _fetchRandomWord();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _fetchRandomWord() async {
    setState(() => _isLoading = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('words').get();
      if (snapshot.docs.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final data = snapshot.docs[_random.nextInt(snapshot.docs.length)].data();
      final firstSense = (data['senses'] as List?)?.firstOrNull;

      setState(() {
        _word = data['mainWord'] ?? '';
        _partOfSpeech = data['mainPos'] ?? '';
        _definition = firstSense?['definition'] ?? '';
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openGoogleTranslate() async {
    if (_word.isEmpty) return;
    final word = Uri.encodeComponent(_word);
    var url = Uri.parse(
        'googletranslate://x-callback-url/translate?sl=en&tl=th&q=$word');

    try {
      final canOpenApp = await canLaunchUrl(url);
      if (canOpenApp) {
        await launchUrl(url);
        return;
      }
      url = Uri.parse('https://translate.google.com/?sl=en&tl=th&text=$word');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      url = Uri.parse('https://translate.google.com/?sl=en&tl=th&text=$word');
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration:
            const WebViewConfiguration(enableJavaScript: true),
      );
    }
  }

  Future<void> _openCambridgeDictionary() async {
    if (_word.isEmpty) return;
    final word = Uri.encodeComponent(_word);
    var url =
        Uri.parse('https://dictionary.cambridge.org/dictionary/english/$word');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration:
            const WebViewConfiguration(enableJavaScript: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
          child: Center(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator())));
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('คำศัพท์ประจำวัน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Lottie.asset(
                'assets/animations/Animation - 1741196193367.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(_word,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            if (_partOfSpeech.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _partOfSpeech,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
            if (_definition.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_definition),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _openGoogleTranslate,
                  icon: const Icon(Icons.translate, size: 20),
                  label: const Text('Google Translate'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _openCambridgeDictionary,
                  icon: const Icon(Icons.menu_book, size: 20),
                  label: const Text('Cambridge'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _flutterTts.speak(_word),
                  icon: const Icon(Icons.volume_up),
                  tooltip: 'ฟังเสียง',
                ),
                IconButton(
                  onPressed: _fetchRandomWord,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'สุ่มคำใหม่',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
