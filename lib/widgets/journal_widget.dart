import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/journal_provider.dart';

class JournalWidget extends StatefulWidget {
  final String category;

  const JournalWidget({Key? key, required this.category}) : super(key: key);

  @override
  _JournalWidgetState createState() => _JournalWidgetState();
}

class _JournalWidgetState extends State<JournalWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // History stacks for undo functionality
  final List<String> _globalJournalHistory = [];
  final List<String> _categoryJournalHistory = [];

  late TextEditingController _globalController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load the initial data from the provider
    final journalProvider =
        Provider.of<JournalProvider>(context, listen: false);
    final globalJournal = journalProvider.globalJournal;
    final categoryJournal = journalProvider.getCategoryJournal(widget.category);

    // Initialize controllers
    _globalController = TextEditingController(text: globalJournal);
    _categoryController = TextEditingController(text: categoryJournal);

    // Initialize history stacks with the initial state
    _globalJournalHistory.add(globalJournal!);
    _categoryJournalHistory.add(categoryJournal!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _globalController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveToHistory(List<String> history, String newValue) {
    if (history.isEmpty || history.last != newValue) {
      history.add(newValue);
      if (history.length > 10) {
        history.removeAt(0); // Keep only the last 10 changes
      }
    }
  }

  void _revertChanges() {
    setState(() {
      if (_tabController.index == 0) {
        // Revert global journal
        if (_globalJournalHistory.length > 1) {
          _globalJournalHistory.removeLast();
          _globalController.text = _globalJournalHistory.last;
        }
      } else {
        // Revert category-specific journal
        if (_categoryJournalHistory.length > 1) {
          _categoryJournalHistory.removeLast();
          _categoryController.text = _categoryJournalHistory.last;
        }
      }
    });
  }

  void _saveJournalData() {
    final journalProvider =
        Provider.of<JournalProvider>(context, listen: false);
    journalProvider.updateGlobalJournal(_globalController.text);
    journalProvider.updateCategoryJournal(
        widget.category, _categoryController.text);
    print(
        "Saved data: Global='${_globalController.text}', Category='${_categoryController.text}'");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveJournalData(); // Save data when modal closes
        return true;
      },
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: 450,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Tab Bar
              TabBar(
                controller: _tabController,
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.deepPurple,
                tabs: [
                  const Tab(text: "Global Journal"),
                  Tab(text: "Journal for ${widget.category}"),
                ],
              ),
              const SizedBox(height: 10),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Global Journal Tab
                    _buildJournalField(
                      _globalController,
                      (value) {
                        _saveToHistory(_globalJournalHistory, value);
                      },
                      "Log general thoughts or reflections here",
                    ),
                    // Specific Journal Tab
                    _buildJournalField(
                      _categoryController,
                      (value) {
                        _saveToHistory(_categoryJournalHistory, value);
                      },
                      "What did you learn or want to remember?",
                    ),
                  ],
                ),
              ),

              // Buttons
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Revert Changes Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _revertChanges,
                        child: const Text(
                          "Revert Changes",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Spacing between buttons

                    // Save and Close Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _saveJournalData();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Save and Close",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalField(
    TextEditingController controller,
    ValueChanged<String> onChanged,
    String hintText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        maxLines: 15,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
        ),
      ),
    );
  }
}
