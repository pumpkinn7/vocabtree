import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VocabScreen extends StatelessWidget {
  const VocabScreen({super.key});

  // ฟังก์ชัน _getLevelFromTopic สำหรับอ้างอิง level จาก topic
  String _getLevelFromTopic(String topic) {
    if (topic.startsWith('daily_life') ||
        topic.startsWith('education') ||
        topic.startsWith('entertainment') ||
        topic.startsWith('environment_and_nature') ||
        topic.startsWith('health_and_fitness') ||
        topic.startsWith('travel_and_tourism')) {
      return 'B1';
    } else if (topic.startsWith('home_renovation_and_decor') ||
        topic.startsWith('outdoor_activities_and_adventures') ||
        topic.startsWith('music_and_performing_arts') ||
        topic.startsWith('fitness_and_exercise') ||
        topic.startsWith('cooking_and_culinary_skills') ||
        topic.startsWith('pet_care_and_animal_welfare') ||
        topic.startsWith('gardening_and_landscaping') ||
        topic.startsWith('hobbies_and_crafts')) {
      return 'B2';
    } else if (topic.startsWith('urban_living') ||
        topic.startsWith('digital_well_being') ||
        topic.startsWith('cultural_festivals') ||
        topic.startsWith('creative_writing') ||
        topic.startsWith('nutrition_and_wellness') ||
        topic.startsWith('interior_decorating') ||
        topic.startsWith('fashion_trends') ||
        topic.startsWith('event_planning')) {
      return 'C1';
    } else if (topic.startsWith('immersive_technologies') ||
        topic.startsWith('cosmic_discoveries') ||
        topic.startsWith('digital_finance') ||
        topic.startsWith('adrenaline_activities') ||
        topic.startsWith('smart_automation') ||
        topic.startsWith('legends_and_lore') ||
        topic.startsWith('criminal_investigation')) {
      return 'C2';
    } else {
      return 'B1';
    }
  }

  @override
  Widget build(BuildContext context) {
    // รับค่า userId จาก Firebase Authentication
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    // กำหนดหัวข้อ (topics) ทั้งหมดที่มีการอ้างอิง
    final List<String> topics = [
      'daily_life',
      'education',
      'entertainment',
      'environment_and_nature',
      'health_and_fitness',
      'travel_and_tourism',
      'home_renovation_and_decor',
      'outdoor_activities_and_adventures',
      'music_and_performing_arts',
      'fitness_and_exercise',
      'cooking_and_culinary_skills',
      'pet_care_and_animal_welfare',
      'gardening_and_landscaping',
      'hobbies_and_crafts',
      'urban_living',
      'digital_well_being',
      'cultural_festivals',
      'creative_writing',
      'nutrition_and_wellness',
      'interior_decorating',
      'fashion_trends',
      'event_planning',
      'immersive_technologies',
      'cosmic_discoveries',
      'digital_finance',
      'adrenaline_activities',
      'smart_automation',
      'legends_and_lore',
      'criminal_investigation'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocab Screen'),
      ),
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          final String level = _getLevelFromTopic(topic);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection(level)
                .doc(topic)
                .collection('vocabularies')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return ListTile(
                  title: Text('Topic: $topic (ไม่พบคำศัพท์)'),
                );
              }

              final vocabDocs = snapshot.data!.docs;

              return ExpansionTile(
                title: Text('Topic: $topic (Level: $level)'),
                children: vocabDocs.map((doc) {
                  final vocabData = doc.data() as Map<String, dynamic>;
                  final word = vocabData['word'] ?? '';
                  final meaning = vocabData['meaning'] ?? '';
                  return ListTile(
                    title: Text(word),
                    subtitle: Text(meaning),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
