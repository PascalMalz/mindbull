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
  late String _originalGlobalJournal;
  late String _originalCategoryJournal;
  late String _tempGlobalJournal;
  late String _tempCategoryJournal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load the original data from the provider
    final journalProvider =
        Provider.of<JournalProvider>(context, listen: false);
    _originalGlobalJournal = journalProvider.globalJournal!;
    _originalCategoryJournal =
        journalProvider.getCategoryJournal(widget.category)!;

    // Initialize temporary variables for editable fields
    _tempGlobalJournal = _originalGlobalJournal;
    _tempCategoryJournal = _originalCategoryJournal;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveJournalData() {
    final journalProvider =
        Provider.of<JournalProvider>(context, listen: false);
    journalProvider.updateGlobalJournal(_tempGlobalJournal);
    journalProvider.updateCategoryJournal(
        widget.category, _tempCategoryJournal);
  }

  void _revertChanges() {
    setState(() {
      // Reset temporary variables to original values
      _tempGlobalJournal = _originalGlobalJournal;
      _tempCategoryJournal = _originalCategoryJournal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    _tempGlobalJournal,
                    (value) => _tempGlobalJournal = value,
                    "Log general thoughts or reflections here",
                  ),
                  // Specific Journal Tab
                  _buildJournalField(
                    _tempCategoryJournal,
                    (value) => _tempCategoryJournal = value,
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
    );
  }

  Widget _buildJournalField(
    String initialValue,
    ValueChanged<String> onChanged,
    String hintText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        maxLines: 15,
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
        ),
      ),
    );
  }
}
