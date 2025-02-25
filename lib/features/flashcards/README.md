# Flashcard Feature

The Flashcard feature provides a way for users to learn and review vocabulary words through an interactive swipeable card interface.

## Architecture

The Flashcard feature follows a clean architecture pattern with:

- **Models**: Data structures representing flashcards
- **Services**: Low-level classes that handle direct API calls
- **Repositories**: Abstract data sources and provide domain-specific methods
- **Controllers**: Business logic separated from UI
- **Screens**: UI components for user interaction
- **Widgets**: Reusable UI components

```
flashcards/
├── controllers/
│   └── flashcard_controller.dart
├── model/
│   └── flashcard_topic_model.dart
├── repositories/
│   └── flashcard_repository.dart
├── screens/
│   ├── flashcard_summary_screen.dart
│   └── flashcard_topic_screen.dart
├── services/
│   └── word_service.dart
├── test/
│   └── flashcard_controller_test.dart
└── widgets/
    ├── flashcard_action_bar.dart
    ├── flashcard_header.dart
    └── flashcard_item.dart
```

## Data Sources

The flashcard feature is designed to work with two different Firebase data structures:

1. **New Structure**: Uses `word_categories` and `words` collections
2. **Legacy Structure**: Uses `cefr_levels` collection with nested topics and vocabularies

The feature attempts to use the new structure first and falls back to the legacy structure if needed.

## Firebase Collections

### New Structure
- `word_categories/{category_id}`: Contains category metadata and an array of word IDs
- `words/{word_id}`: Contains word data including senses, definitions, and examples

### Legacy Structure
- `cefr_levels/{level}/topics/{topic}/vocabularies`: Contains vocabulary items for each topic

### User Data
- `users/{user_id}/{level}/{topic}/vocabularies/{word}`: Stores the user's progress for each word

## Usage

To use the Flashcard feature in your app:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => FlashcardScreen(
      topic: 'daily_life', // Category ID
      userId: currentUser.id,
    ),
  ),
);
```

## Key Components

### FlashcardScreen
Main screen that displays flashcards with swipe actions.

### FlashcardSummaryScreen
Shown after completing a flashcard session, displaying statistics and allowing users to add unknown words to their review bank.

### FlashcardController
Handles business logic for fetching flashcards, saving user progress, and managing the flashcard flow.

### WordService
Provides methods to interact with the Firebase data structure for words and categories.

### FlashcardRepository
Abstracts the data access layer and provides domain-specific methods for working with flashcards.
