import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vocabtree/features/vocab/vocab_screen.dart';

class AllVocabScreen extends StatefulWidget {
  final String level;

  const AllVocabScreen({super.key, required this.level});

  @override
  AllVocabScreenState createState() => AllVocabScreenState();
}

class AllVocabScreenState extends State<AllVocabScreen> {
  String? userId;
  List<DocumentSnapshot> allVocabDocs = [];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchAllVocabularies();
  }

  Future<void> _fetchAllVocabularies() async {
    List<DocumentSnapshot> vocabDocs = [];
    // เข้าถึง levelMapping จาก VocabScreenState
    final topics = VocabScreenState.levelMapping[widget.level] ?? [];
    for (var topic in topics) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(widget.level)
          .doc(topic)
          .collection('vocabularies')
          .get();

      vocabDocs.addAll(snapshot.docs);
    }

    setState(() {
      allVocabDocs = vocabDocs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คำศัพท์ทั้งหมด ระดับ ${widget.level}'),
      ),
      body: allVocabDocs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: allVocabDocs.length,
        itemBuilder: (context, index) {
          final vocabData = allVocabDocs[index].data() as Map<String, dynamic>;
          final word = vocabData['word'] ?? '';
          final type = vocabData['type'] ?? '';
          final meaning = vocabData['meaning'] ?? '';

          return ListTile(
            title: Text('$word - $type'),
            subtitle: Text(meaning),
            onTap: () {
              // คุณสามารถเพิ่มฟังก์ชันเมื่อผู้ใช้แตะที่คำศัพท์ได้ที่นี่
            },
          );
        },
      ),
    );
  }
}
