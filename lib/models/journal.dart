import 'package:flutter/material.dart';

class JournalProvider with ChangeNotifier {
  String _globalJournal = "";
  Map<String, String> _categoryJournals = {};

  // Getter for global journal
  String get globalJournal => _globalJournal;

  // Getter for category-specific journal
  String getCategoryJournal(String category) =>
      _categoryJournals[category] ?? "";

  // Update global journal
  void updateGlobalJournal(String journal) {
    _globalJournal = journal;
    notifyListeners(); // Notify listeners of changes
  }

  // Update category-specific journal
  void updateCategoryJournal(String category, String journal) {
    _categoryJournals[category] = journal;
    notifyListeners(); // Notify listeners of changes
  }
}
