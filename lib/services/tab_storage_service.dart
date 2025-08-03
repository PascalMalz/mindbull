import 'package:hive/hive.dart';
import '../models/tab_content_item.dart';
import 'dart:convert';

class TabStorageService {
  final Box<String> _box = Hive.box<String>('tab_storage');

  static const String tabsKey = 'tabs';

  /// Returns all tab IDs from the saved tabs list, sorted by order if available
  List<String> getAllTabIds() {
    final rawJson = _box.get(tabsKey);
    if (rawJson == null) return [];

    final List<dynamic> decoded = jsonDecode(rawJson);

    decoded.sort((a, b) => (a['order'] ?? 999).compareTo(b['order'] ?? 999));

    return decoded
        .map((tab) => tab['tab_id'] as String)
        .where((id) => id.isNotEmpty)
        .toList();
  }

  /// Returns the display name for a given tab ID
  String getTabName(String tabId) {
    final rawJson = _box.get(tabsKey);
    if (rawJson == null) return 'Unnamed Tab';

    final List<dynamic> decoded = jsonDecode(rawJson);
    final tab = decoded.firstWhere(
      (t) => t['tab_id'] == tabId,
      orElse: () => null,
    );

    if (tab == null) return 'Unnamed Tab';

    return tab['display_name'] ?? tab['name'] ?? tab['title'] ?? 'Unnamed Tab';
  }

  String _tabContentKey(String tabId) => 'tabContent:$tabId';

  /// Loads content items for a given tab
  List<TabContentItem> getItems(String tabId) {
    final rawJson = _box.get(_tabContentKey(tabId));
    if (rawJson == null) return [];

    final List<dynamic> decoded = jsonDecode(rawJson);
    return decoded
        .map((e) => TabContentItem.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void addItem(String tabId, TabContentItem item) {
    final items = getItems(tabId);
    final updated = [...items, item.copyWith(order: items.length)];
    _saveItems(tabId, updated);
  }

  void removeItem(String tabId, String itemId) {
    final items = getItems(tabId)..removeWhere((e) => e.id == itemId);
    _saveItems(tabId, items);
  }

  void updateItem(String tabId, TabContentItem updatedItem) {
    final updated = getItems(tabId).map((e) {
      return e.id == updatedItem.id ? updatedItem : e;
    }).toList();
    _saveItems(tabId, updated);
  }

  void reorderItems(String tabId, int oldIndex, int newIndex) {
    final items = getItems(tabId);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(order: i);
    }

    _saveItems(tabId, items);
  }

  void _saveItems(String tabId, List<TabContentItem> items) {
    final jsonList = items.map((e) => e.toJson()).toList();
    _box.put(_tabContentKey(tabId), jsonEncode(jsonList));
  }

  /// Overwrites the full list of tabs
  Future<void> saveTabs(List<Map<String, dynamic>> tabs) async {
    await _box.put(tabsKey, jsonEncode(tabs));
  }

  /// Clears all tabs and their contents
  void clearAllTabs() {
    final tabIds = getAllTabIds();
    for (final id in tabIds) {
      _box.delete(_tabContentKey(id));
    }
    _box.delete(tabsKey);
  }

  /// Adds or updates a single tab entry from backend
  Future<void> addOrUpdateTabFromBackend({
    required String tabId,
    required String displayName,
    int? order,
    bool? isDefault,
  }) async {
    final rawJson = _box.get(tabsKey);
    final List<dynamic> decoded = rawJson != null ? jsonDecode(rawJson) : [];

    // Remove old entry if exists
    decoded.removeWhere((tab) => tab['tab_id'] == tabId);

    // Add updated one
    decoded.add({
      'tab_id': tabId,
      'display_name': displayName,
      if (order != null) 'order': order,
      if (isDefault != null) 'is_default': isDefault,
    });

    await _box.put(tabsKey, jsonEncode(decoded));
  }
}
