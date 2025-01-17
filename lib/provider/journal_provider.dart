import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class JournalProvider with ChangeNotifier {
  final Box<String> journalBox;

  JournalProvider({required this.journalBox});

  // Get global journal
  String? get globalJournal =>
      journalBox.get('globalJournal', defaultValue: '');

  // Get journal for a specific category
  String? getCategoryJournal(String category) =>
      journalBox.get(category, defaultValue: '');

  // Update global journal
  void updateGlobalJournal(String journal) {
    journalBox.put('globalJournal', journal);
    notifyListeners();
  }

  // Update category-specific journal
  void updateCategoryJournal(String category, String journal) {
    journalBox.put(category, journal);
    notifyListeners();
  }
}
