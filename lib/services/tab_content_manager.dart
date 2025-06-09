import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/tab_content_item.dart';

/// Tab metadata manager for tracking tab names separately from content.
class TabContentManager {
  final Box<List> _contentBox = Hive.box<List>('tabContent');
  final Box<String> _metadataBox =
      Hive.box<String>('tabMetadata'); // tabId -> name
  final uuid = Uuid();

  /// Returns all tab IDs
  List<String> getAllTabIds() {
    return _metadataBox.keys.cast<String>().toList();
  }

  /// Returns the display name for a tab
  String getTabName(String tabId) {
    return _metadataBox.get(tabId) ?? 'Unnamed Tab';
  }

  /// Updates the display name for a tab
  void renameTab(String tabId, String newName) {
    _metadataBox.put(tabId, newName);
  }

  /// Returns a map of all tabId -> tabName
  Map<String, String> getAllTabNames() {
    return Map.fromEntries(
      _metadataBox.keys.map((k) => MapEntry(k, _metadataBox.get(k)!)),
    );
  }

  /// Create a new tab and return its generated ID
  String createTab(String tabName) {
    final id = uuid.v4();
    _metadataBox.put(id, tabName);
    _contentBox.put(id, []);
    return id;
  }

  /// Delete a tab and its content
  void deleteTab(String tabId) {
    _metadataBox.delete(tabId);
    _contentBox.delete(tabId);
  }

  /// Get items by tab ID
  List<TabContentItem> getItems(String tabId) {
    final raw = _contentBox.get(tabId) ?? [];
    return raw
        .map((e) => TabContentItem.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Save all items under tab ID
  void saveItems(String tabId, List<TabContentItem> items) {
    _contentBox.put(tabId, items.map((e) => e.toJson()).toList());
  }

  /// Add an item to a tab
  void addItem(String tabId, TabContentItem item) {
    final items = getItems(tabId);
    final updated = [...items, item.copyWith(order: items.length)];
    saveItems(tabId, updated);
  }

  /// Reorder items in a tab
  void reorderItems(String tabId, int oldIndex, int newIndex) {
    final items = getItems(tabId);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(order: i);
    }

    saveItems(tabId, items);
  }

  /// Remove an item by ID
  void removeItem(String tabId, String itemId) {
    final items = getItems(tabId)..removeWhere((e) => e.id == itemId);
    saveItems(tabId, items);
  }

  /// Update a specific item
  void updateItem(String tabId, TabContentItem updatedItem) {
    final items = getItems(tabId).map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();

    saveItems(tabId, items);
  }
}
