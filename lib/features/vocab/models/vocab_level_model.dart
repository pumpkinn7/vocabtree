class VocabLevelModel {
  final String level;
  final List<String> topics;

  VocabLevelModel({
    required this.level,
    required this.topics,
  });

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

  static List<VocabLevelModel> getAllLevels() {
    return levelMapping.entries
        .map((entry) => VocabLevelModel(
              level: entry.key,
              topics: entry.value,
            ))
        .toList();
  }
}
