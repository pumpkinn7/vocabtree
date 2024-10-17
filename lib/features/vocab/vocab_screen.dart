import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VocabScreen extends StatelessWidget {
  const VocabScreen({super.key});

  static const Map<String, List<String>> levelMapping = {
    'B1': [
      'daily_life',
      'education',
      'entertainment',
      'environment_and_nature',
      'health_and_fitness',
      'travel_and_tourism',
    ],
    'B2': [
      'home_renovation_and_decor',
      'outdoor_activities_and_adventures',
      'music_and_performing_arts',
      'fitness_and_exercise',
      'cooking_and_culinary_skills',
      'pet_care_and_animal_welfare',
      'gardening_and_landscaping',
      'hobbies_and_crafts',
    ],
    'C1': [
      'urban_living',
      'digital_well_being',
      'cultural_festivals',
      'creative_writing',
      'nutrition_and_wellness',
      'interior_decorating',
      'fashion_trends',
      'event_planning',
    ],
    'C2': [
      'immersive_technologies',
      'cosmic_discoveries',
      'digital_finance',
      'adrenaline_activities',
      'smart_automation',
      'legends_and_lore',
      'criminal_investigation',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Screen')),
      body: ListView(
        children: levelMapping.entries.map((levelEntry) {
          final level = levelEntry.key;
          final topics = levelEntry.value;

          return ExpansionTile(
            title: Text('ระดับ: $level'),
            children: topics.map((topic) {
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection(level)
                    .doc(topic)
                    .collection('vocabularies')
                    .where('for_review', isEqualTo: true)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ListTile(title: Text('เกิดข้อผิดพลาดในการโหลดหัวข้อ: $topic'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('กำลังโหลดหัวข้อ...'));
                  }

                  final vocabDocs = snapshot.data?.docs ?? [];

                  if (vocabDocs.isEmpty) {
                    return SizedBox.shrink(); // ไม่มีคำศัพท์ไม่แสดงหัวข้อนี้
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // จัดหัวข้อให้อยู่ตรงกลาง
                      children: [
                        Text(
                          'หัวข้อ: $topic',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center, // จัดข้อความให้อยู่ตรงกลาง
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          spacing: 12.0,
                          runSpacing: 12.0,
                          alignment: WrapAlignment.center, // จัดปุ่มให้อยู่ตรงกลาง
                          children: vocabDocs.map((doc) {
                            final vocabData = doc.data() as Map<String, dynamic>;
                            final word = vocabData['word'] ?? '';
                            return OutlinedButton(
                              onPressed: () {
                                // Handle button press (เช่นเปิดรายละเอียดของคำศัพท์)
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                side: BorderSide(color: Theme.of(context).primaryColor), // ปรับสีขอบตามธีม
                              ),
                              child: Text(word, textAlign: TextAlign.center),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
