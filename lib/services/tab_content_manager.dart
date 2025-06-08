import 'package:hive/hive.dart';
import 'package:mindbull/models/tab_content_item.dart';

class TabContentManager {
  final Box<List> _box = Hive.box<List>('tabContent');

  List<TabContentItem> getItems(String tabName) {
    final raw = _box.get(tabName) ?? [];
    return raw
        .map((e) => TabContentItem.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void saveItems(String tabName, List<TabContentItem> items) {
    _box.put(tabName, items.map((e) => e.toJson()).toList());
  }

  void addItem(String tabName, TabContentItem item) {
    final items = getItems(tabName);
    final updated = [...items, item.copyWith(order: items.length)];
    saveItems(tabName, updated);
  }

  void reorderItems(String tabName, int oldIndex, int newIndex) {
    final items = getItems(tabName);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(order: i);
    }

    saveItems(tabName, items);
  }

  void removeItem(String tabName, String itemId) {
    final items = getItems(tabName)..removeWhere((e) => e.id == itemId);
    saveItems(tabName, items);
  }

  void updateItem(String tabName, TabContentItem updatedItem) {
    final items = getItems(tabName).map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();

    saveItems(tabName, items);
  }
}
