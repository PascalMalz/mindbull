import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mindbull/api/api_tab_content_service.dart';
import 'package:mindbull/api/tab_api.dart';
import 'package:mindbull/models/exercise.dart';
import 'package:mindbull/models/tab_content_link.dart';
import 'package:mindbull/services/tab_storage_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:mindbull/main.dart';
import 'package:mindbull/models/tab_content_item.dart';
import 'package:mindbull/pages/favorites_picker_screen.dart';
import 'package:mindbull/pages/favorites_screen.dart';

import 'package:mindbull/widgets/checklist_widget.dart';
import 'package:provider/provider.dart';
import 'package:mindbull/pages/goals_standalone.dart';
import 'package:mindbull/pages/intro.dart';
import 'package:mindbull/provider/auth_provider.dart';
import '../pages/exercise_display_screen.dart';
import '../provider/journal_provider.dart';
import '../provider/user_data_provider.dart';
import '../widgets/common_bottom_navigation_bar.dart';
import '../widgets/journal_widget.dart';
import 'package:uuid/uuid.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  _HomeScreenV2State createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2>
    with TickerProviderStateMixin {
  TabController? _tabController;
  bool _tabsLoadedAfterLogin = false;
  bool _startedLoadingTabs = false;
  bool _isLoadingTabs = true;
  final TabStorageService _tabManager = TabStorageService();
  List<String> tabIds = [];

  final List<String> defaultTabNames = [
    "My Daily",
    "Affirmation",
    "Visualization",
    "Reframing",
    "Meditation",
    "Gratitude",
    "Motivation",
    "Acceptance",
  ];

/*   void initDefaultTabsIfEmpty() {
    final existing = _tabManager.getAllTabIds();
    if (existing.isEmpty) {
      for (var name in defaultTabNames) {
        _tabManager.createTab(name);
      }
    }
  } */

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user =
          Provider.of<UserDataProvider>(context, listen: false).currentUser;
      if (user != null && !_startedLoadingTabs) {
        _startedLoadingTabs = true;
        print("📥 loadDefaultTabs() triggered");
        await loadDefaultTabs(); // Will setState internally
      } else {
        print("🧩 setState: triggering UI after loading from INIT!");
        setState(() {
          _isLoadingTabs = false;
        });
        print("✅ setState INIT completed");
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserDataProvider>(context).currentUser;

    if (user != null && !_startedLoadingTabs) {
      _startedLoadingTabs = true;
      loadDefaultTabs();
    }
  }

  void _initTabController() {
    print("🛠 _initTabController called");
    final latestTabIds = _tabManager.getAllTabIds();
    print("🧩 _initTabController → fetched tabIds from Hive: $latestTabIds");

    if (latestTabIds.isEmpty) {
      print(
          "⚠️ _initTabController → tab list is empty, skipping controller init");
      return;
    }

    final tabCount = latestTabIds.length + 1;

    _tabController?.dispose();
    _tabController = TabController(length: tabCount, vsync: this);

    tabIds = latestTabIds;

    print("✅ _initTabController → CREATED: tabCount=$tabCount, tabIds=$tabIds");
  }

  Future<void> loadDefaultTabs() async {
    print("📥 loadDefaultTabs() triggered");
    try {
      final defaultTabs = await TabApi().fetchDefaultTabs();
      print("📦 Tabs fetched from API: $defaultTabs");

      await _tabManager.saveTabs(defaultTabs);
      print("💾 Tabs saved to Hive");

      final allTabIds = _tabManager.getAllTabIds();
      print("📤 Read back from Hive: tabIds=$allTabIds");

      tabIds = allTabIds;
      _initTabController();
      print("🧩 setState: triggering UI after loading from loadDefaultTabs");
      setState(() {
        _tabsLoadedAfterLogin = true;
        _isLoadingTabs = false;
      });
      print("✅ setState completed from loadDefaultTabs");
      // ✅ Force TabController sync one last time
      Future.microtask(() {
        print("🔁 Final microtask sync...");
        _initTabController();
        print(
            "🧩 setState: triggering UI after loading from loadDefaultTabs microtask");
        setState(() {
          tabIds = _tabManager.getAllTabIds(); // 👈 force tabIds refresh too
          _tabsLoadedAfterLogin = true;
          _isLoadingTabs = false;
        });
        print("✅ setState completed in loadDefaultTabs microtask");
      });
    } catch (e, stack) {
      print("❌ Exception in loadDefaultTabs: $e");
      print("📉 Stacktrace: $stack");
      setState(() {
        _isLoadingTabs = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  AppBar buildAppBar(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final username = userDataProvider.currentUser?.username ?? 'Not Logged In';

    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.deepPurple),
      title: const Text(
        'Daily Mind Workout',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      ),
      elevation: 0,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  void _showJournalBottomSheet(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return JournalWidget(category: category);
      },
    );
  }

  void _renameTab(BuildContext context, String tabId) async {
    final currentName = _tabManager.getTabName(tabId);
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Tab"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        "🔥 build() called. _isLoadingTabs=$_isLoadingTabs, _tabController=${_tabController?.length}, tabIds=$tabIds");
    if (_tabController != null) {
      print(
          "🧪 TabController length: ${_tabController!.length}, expected: ${tabIds.length + 1}");
    } else {
      print('tabcontroller is null!!!');
    }
    final user = Provider.of<UserDataProvider>(context).currentUser;

    print("🧠 Rebuilding HomeScreenV2");
    print("🧠 Logged in user: ${user?.username ?? "none"}");
    print("🧠 _tabsLoadedAfterLogin: $_tabsLoadedAfterLogin");
    // ✅ SAFE PRINTING
    for (final id in tabIds) {
      final name = _tabManager.getTabName(id);
      print("→ $id = $name");
    }
    return CommonBottomNavigationBar(
      currentIndex: 0,
      builder: (context) {
        return Scaffold(
          appBar: buildAppBar(context),
          endDrawer: buildRightBar(),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              const SizedBox(height: 0),
              if (_tabController == null)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.deepPurple,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.black,
                  padding: const EdgeInsets.only(left: 2),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                  tabs: [
                    ...tabIds.map((tabId) {
                      final name = _tabManager.getTabName(tabId);
                      print("🔠 Rendering TabBar tab ➜ ID=$tabId ➜ Name=$name");

                      return GestureDetector(
                        onLongPress: () => _renameTab(context, tabId),
                        child: Tab(text: name),
                      );
                    }),
                    const Tab(
                        icon: Icon(Icons.add,
                            size: 28, color: Colors.deepPurple)),
                  ],
                ),
              const SizedBox(height: 0),
              Builder(builder: (context) {
                print(
                    "🧪 build() called: _isLoadingTabs=$_isLoadingTabs, _tabController=${_tabController?.length}, tabIds=${tabIds.length}");
                return Expanded(
                  child: (_isLoadingTabs ||
                          _tabController == null ||
                          tabIds.isEmpty)
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: List.generate(tabIds.length + 1, (index) {
                            if (index >= tabIds.length) {
                              return Center(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add New Tab"),
                                  onPressed: () {
                                    print("➕ Add new tab clicked");
                                    //_showAddTabDialog(); // your custom dialog
                                  },
                                ),
                              );
                            }

                            final tabId = tabIds[index];
                            final name = _tabManager.getTabName(tabId);
                            print('🔠 Building tab $index → $tabId');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TabContentEditorView(tabId: tabId),
                                ),
                                InkWell(
                                  onTap: () =>
                                      _showJournalBottomSheet(context, name),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "Open Journal",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.edit,
                                            color: Colors.deepPurple),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  endIndent: 12,
                                  indent: 12,
                                  height: 1,
                                  color: Color.fromARGB(123, 158, 158, 158),
                                ),
                              ],
                            );
                          }),
                        ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Drawer buildRightBar() {
    return Drawer(
      child: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          final user = userDataProvider.currentUser;
          final username = user?.username ?? 'Not Logged In';

          // Determine the background image for the profile picture
          String? profilePictureUrl = user?.profilePictureUrl;
          ImageProvider<Object> backgroundImage =
              (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                  ? NetworkImage(profilePictureUrl)
                  : const AssetImage('assets/default_profile_picture.png');

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: backgroundImage,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.auto_graph),
                title: const Text('Goals'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoalsStandalone(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.question_mark),
                title: const Text('Watch Intro Again'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Intro()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notification_important),
                title: const Text('Notifications'),
                onTap: () {
                  // Implement notifications logic here
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Data Protection'),
                onTap: () {
                  // Implement data protection logic here
                },
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: const Text('Account'),
                onTap: () {
                  // Implement account logic here
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Implement settings logic here
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Print User Data'),
                onTap: () {
                  print('User name: ${userDataProvider.currentUser?.username}');
                  setState(() {}); // Update UI if needed
                },
              ),
              if (user == null)
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Log In'),
                  onTap: () async {
                    final loggedIn = await Navigator.pushNamed(
                      context,
                      '/authentication',
                      arguments: {'redirectRoute': '/'},
                    );
                  },
                ),
              if (user != null)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log Out'),
                  onTap: () async {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    authProvider.logout();
                    setState(() {}); // Update UI after logout
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class TabContentEditorView extends StatefulWidget {
  final String tabId;

  const TabContentEditorView({super.key, required this.tabId});

  @override
  State<TabContentEditorView> createState() => _TabContentEditorViewState();
}

class _TabContentEditorViewState extends State<TabContentEditorView> {
  final TabStorageService _tabManager = TabStorageService();
  final uuid = Uuid();
  late List<TabContentItem> items;
  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    _loadTabContent();
  }

  Future<void> _loadTabContent() async {
    items = _tabManager.getItems(widget.tabId); // ← Local Hive fallback
    final api = ApiTabContentService();
    final List<TabContentLink> links =
        await api.fetchTabContentLinks(widget.tabId);

    final List<Exercise> loadedExercises = [];

    for (var link in links) {
      if (link.contentType == 'exercise') {
        final exercise = Exercise.fromJson(link.contentObject);
        loadedExercises.add(exercise);
      }
      // TODO: handle checklists, reminders, etc.
    }

    setState(() {
      exercises = loadedExercises;
    });
  }

  final TabApi tabApi = TabApi();

  void loadTabs() async {
    try {
      final tabs = await tabApi.fetchDefaultTabs();
      print("Tabs loaded: $tabs");
      // Pass to your TabContentManager or UI state handler here
    } catch (e) {
      print("Failed to load tabs: $e");
    }
  }

  void _updateOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    _tabManager.reorderItems(widget.tabId, oldIndex, newIndex);
    setState(() {
      items = _tabManager.getItems(widget.tabId);
    });
  }

  void _removeItem(String id) {
    _tabManager.removeItem(widget.tabId, id);
    setState(() {
      items = _tabManager.getItems(widget.tabId);
    });
  }

  void _showAddItemModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Content Type",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.deepPurple),
                    title: const Text('From Favourites'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleAddFromFavourites();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.library_books,
                        color: Colors.deepPurple),
                    title: const Text('From Library'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleAddFromLibrary();
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.check_box, color: Colors.deepPurple),
                    title: const Text('Checklist'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleAddChecklist();
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.audiotrack, color: Colors.deepPurple),
                    title: const Text('Audio File'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleAddAudio();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.horizontal_rule,
                        color: Colors.deepPurple),
                    title: const Text('Content Separator'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleAddSeparator();
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.queue_music, color: Colors.deepPurple),
                    title: const Text('Audio Playlist'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleAddAudioPlaylist();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.alarm, color: Colors.deepPurple),
                    title: const Text('Reminder'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleAddReminder();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleAddFromFavourites() async {
    final selectedItems = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesPickerScreen()),
    );

    if (selectedItems != null && selectedItems is List) {
      for (var item in selectedItems) {
        final id = item['data']['exercise_uuid'] ??
            item['data']['post_id'] ??
            item['data']['audio_id'];
        final type = item['content_type'];

        final tabItem = TabContentItem(
          id: id,
          type: TabContentType.fromString(type), // Add this converter if needed
          title: item['data']['name'] ??
              item['data']['title'] ??
              item['data']['content'] ??
              'Favorite',
          order: items.length,
          metadata: item['data'],
        );

        _tabManager.addItem(widget.tabId, tabItem);
      }

      setState(() {
        items = _tabManager.getItems(widget.tabId);
      });
    }
  }

  void _handleAddFromLibrary() {
    // TODO: Open your library screen and pick an item
    print("From Library tapped");
  }

  void _handleAddChecklist() {
    final newItem = TabContentItem(
      id: UniqueKey().toString(),
      type: TabContentType.checklist,
      title: 'My Checklist',
      order: items.length,
      metadata: {
        'items': [
          {'title': 'Task 1', 'checked': false},
          {'title': 'Task 2', 'checked': false},
        ],
      },
    );
    _tabManager.addItem(widget.tabId, newItem);
    setState(() {
      items = _tabManager.getItems(widget.tabId);
    });
  }

  void _handleAddAudio() {
    // TODO: File picker or local audio reference
    print("Audio tapped");
  }

  void _handleAddSeparator() {
    final newItem = TabContentItem(
      id: uuid.v4(),
      type: TabContentType.separator,
      title: 'Morning Routine', // Default label, can be edited later
      order: items.length,
      metadata: {
        'label': 'Morning Routine',
      },
    );
    _tabManager.addItem(widget.tabId, newItem);
    setState(() {
      items = _tabManager.getItems(widget.tabId);
    });
  }

  void _handleAddAudioPlaylist() {
    final newItem = TabContentItem(
      id: UniqueKey().toString(),
      type: TabContentType.audioPlaylist,
      title: 'My Audio Playlist',
      order: items.length,
      metadata: {
        'audios': [], // start empty; populate later
      },
    );
    _tabManager.addItem(widget.tabId, newItem);
    setState(() {
      items = _tabManager.getItems(widget.tabId);
    });
  }

  void _handleAddReminder() {
    final newItem = TabContentItem(
      id: uuid.v4(),
      type: TabContentType.reminder,
      title: 'Reminder',
      order: items.length,
      metadata: {
        'time': '08:00', // default reminder time
        'note': 'Your reminder text here',
      },
    );

    _tabManager.addItem(widget.tabId, newItem);
    setState(() {
      items = _tabManager.getItems(widget.tabId);
    });

    _scheduleReminderNotification(newItem); // 🔔 Schedule the reminder
  }

  Future<bool?> _showEditReminderDialog(TabContentItem item) async {
    final TextEditingController noteController =
        TextEditingController(text: item.metadata?['note'] ?? '');
    TimeOfDay initialTime = _parseTime(item.metadata?['time']) ??
        const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay? pickedTime = initialTime;

    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Reminder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noteController,
                    decoration:
                        const InputDecoration(labelText: 'Reminder Note'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scheduled Time: ${pickedTime?.format(context) ?? 'Not selected'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: const Text('Pick Time'),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: pickedTime ?? initialTime,
                      );
                      if (picked != null) {
                        setState(() {
                          pickedTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    final updatedItem = item.copyWith(
                      metadata: {
                        'note': noteController.text,
                        'time': _formatTimeOfDay(pickedTime!),
                      },
                    );
                    _tabManager.updateItem(widget.tabId, updatedItem);
                    _scheduleReminderNotification(updatedItem);
                    Navigator.pop(context, true); // Return success
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Schedules a daily reminder using awesome_notifications
  Future<void> _scheduleReminderNotification(TabContentItem item) async {
    final timeStr = item.metadata?['time'];
    final note = item.metadata?['note'] ?? 'Reminder';

    if (timeStr == null) return;

    final timeParts = timeStr.split(':');
    final hour = int.tryParse(timeParts[0] ?? '');
    final minute = int.tryParse(timeParts[1] ?? '');

    if (hour == null || minute == null) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // If the scheduled time is in the past, schedule for the next day
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: item.id.hashCode,
        channelKey: 'basic_channel',
        title: 'Mindbull Reminder',
        body: note,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        millisecond: 0,
        repeats: true, // Makes it a daily reminder
      ),
    );
    // Show confirmation SnackBar
    final timeFormatted =
        "${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for $timeFormatted: "$note"'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("📦 TabContentEditorView: Loading items for Tab ID=${widget.tabId}");
    return Column(
      children: [
        Expanded(
          child: Material(
            color: Colors.white,
            child: ReorderableListView.builder(
                itemCount: items.length,
                onReorder: _updateOrder,
                itemBuilder: (context, index) {
                  final item = items[index];

                  if (item.type == TabContentType.separator) {
                    return Column(
                      key: ValueKey(item.id),
                      children: [
                        const Divider(
                            thickness: 2, height: 0, color: Colors.deepPurple),
                        ListTile(
                          tileColor: Colors.deepPurple.shade50,
                          title: Text(
                            item.metadata?['label'] ?? 'Separator',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 16,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'rename') {
                                final newLabel = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    String editedLabel =
                                        item.metadata?['label'] ?? 'Separator';
                                    return AlertDialog(
                                      title: const Text("Rename Separator"),
                                      content: TextField(
                                        autofocus: true,
                                        controller: TextEditingController(
                                            text: editedLabel),
                                        onChanged: (value) =>
                                            editedLabel = value,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context)
                                              .pop(editedLabel),
                                          child: const Text("Save"),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (newLabel != null && newLabel.isNotEmpty) {
                                  final updatedItem = item.copyWith(
                                    metadata: {
                                      ...?item.metadata,
                                      'label': newLabel
                                    },
                                  );
                                  _tabManager.updateItem(
                                      widget.tabId, updatedItem);

                                  setState(() {
                                    items = _tabManager.getItems(widget.tabId);
                                  });
                                }
                              } else if (value == 'delete') {
                                _removeItem(item.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  if (item.type == TabContentType.audioPlaylist) {
                    return ListTile(
                      key: ValueKey(item.id),
                      tileColor: Colors.deepPurple.shade50,
                      title: Text(
                        item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                      subtitle: const Text('Audio Playlist'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeItem(item.id),
                      ),
                    );
                  }
                  if (item.type == TabContentType.reminder) {
                    return ListTile(
                      key: ValueKey(item.id),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      leading: const Icon(Icons.alarm, size: 20),
                      title: Text(
                        item.metadata?['note'] ?? 'Reminder',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.metadata?['time'] ?? '--:--',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final updated =
                                    await _showEditReminderDialog(item);
                                if (updated == true) {
                                  setState(() {
                                    items = _tabManager.getItems(widget.tabId);
                                  });
                                }
                              } else if (value == 'delete') {
                                _removeItem(item.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  if (item.type == TabContentType.checklist) {
                    return ChecklistWidget(
                      key: ValueKey(item.id),
                      item: item,
                      onUpdate: (updatedItem) {
                        _tabManager.updateItem(widget.tabId, updatedItem);
                        setState(() {
                          items = _tabManager.getItems(
                              widget.tabId); // force re-read from Hive
                        });
                      },
                      onDelete: () {
                        _removeItem(item.id);
                      },
                    );
                  }

                  // 🟩 Default rendering for all other content types
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.title),
                    subtitle: Text(item.type.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(item.id),
                    ),
                  );
                }),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Elements'),
              onPressed: () {
                _showAddItemModal(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                //backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
