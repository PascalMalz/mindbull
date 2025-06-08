// checklist_widget.dart
// A widget to display and manage a checklist with a header, editable items, and remove option.

import 'package:flutter/material.dart';
import 'package:mindbull/models/tab_content_item.dart';

class ChecklistWidget extends StatefulWidget {
  final TabContentItem item;
  final void Function(TabContentItem updatedItem) onUpdate;
  final void Function()? onDelete;

  const ChecklistWidget({
    required this.item,
    required this.onUpdate,
    this.onDelete,
    super.key,
  });

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  late String checklistTitle = widget.item.title;

  List<Map<String, dynamic>> checklistItems = [];

  @override
  void initState() {
    super.initState();

    checklistTitle =
        widget.item.title.isNotEmpty ? widget.item.title : "Checklist";

    final rawItems = widget.item.metadata?['items'];
    if (rawItems is List) {
      checklistItems =
          rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else {
      checklistItems = [];
    }
  }

  void _addItem(String title) {
    setState(() {
      checklistItems.add({'title': title, 'checked': false});
    });
    _updateParent();
  }

  void _removeItem(int index) {
    setState(() {
      checklistItems.removeAt(index);
    });
    _updateParent();
  }

  void _renameItem(int index, String newTitle) {
    setState(() {
      checklistItems[index]['title'] = newTitle;
    });
    _updateParent();
  }

  void _renameChecklist() {
    final controller = TextEditingController(text: checklistTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Checklist"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: "New checklist name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                checklistTitle = controller.text;
              });
              _updateParent();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _updateParent() {
    widget.onUpdate(widget.item.copyWith(
      title: checklistTitle,
      metadata: {'items': checklistItems},
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Header with options
            Row(
              children: [
                Expanded(
                  child: Text(
                    checklistTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'rename') {
                      _renameChecklist();
                    } else if (value == 'delete') {
                      if (widget.onDelete != null) widget.onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'rename', child: Text('Rename Checklist')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete Checklist')),
                  ],
                )
              ],
            ),
            const Divider(),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: checklistItems.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = checklistItems.removeAt(oldIndex);
                  checklistItems.insert(newIndex, item);
                });
                _updateParent();
              },
              itemBuilder: (context, index) {
                final item = checklistItems[index];
                return ListTile(
                  key: ValueKey('$index-${item['title']}'),
                  title: Text(item['title'] ?? 'Unnamed'),
                  leading: Checkbox(
                    value: item['checked'],
                    onChanged: (val) {
                      setState(() {
                        item['checked'] = val;
                      });
                      _updateParent();
                    },
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameDialog(index);
                      } else if (value == 'delete') {
                        _removeItem(index);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'rename', child: Text('Rename')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
              onPressed: () {
                final controller = TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Add Checklist Item"),
                    content: TextField(
                      controller: controller,
                      decoration:
                          const InputDecoration(labelText: "Item title"),
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel")),
                      TextButton(
                        onPressed: () {
                          _addItem(controller.text);
                          Navigator.pop(context);
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(int index) {
    final controller =
        TextEditingController(text: checklistItems[index]['title']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Item"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: "New title"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _renameItem(index, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
