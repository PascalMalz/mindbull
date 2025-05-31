import 'package:flutter/material.dart';
import 'package:mindbull/models/tab_content_item.dart';
import 'package:mindbull/pages/favorites_picker_screen.dart';
import 'package:mindbull/pages/favorites_screen.dart';
import 'package:mindbull/services/tab_content_manager.dart';
import 'package:provider/provider.dart';
import 'package:mindbull/pages/goals_standalone.dart';
import 'package:mindbull/pages/intro.dart';
import 'package:mindbull/provider/auth_provider.dart';
import '../pages/exercise_display_screen.dart';
import '../provider/journal_provider.dart';
import '../provider/user_data_provider.dart';
import '../widgets/common_bottom_navigation_bar.dart';
import '../widgets/journal_widget.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  _HomeScreenV2State createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> categories = [
    'Daily',
    'Affirmation',
    'Visualization',
    'Reframing',
    'Meditation',
    'Gratitude',
    'Motivation',
    'Acceptance',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return CommonBottomNavigationBar(
      currentIndex: 0,
      child: Scaffold(
        appBar: buildAppBar(context),
        endDrawer: buildRightBar(),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.deepPurple,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.black,
              tabs: [
                ...categories.map((category) => Tab(text: category)),
                const Tab(
                  child: Icon(
                    Icons.add,
                    size: 24,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ...categories.map((category) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: category == 'Daily'
                              ? TabContentEditorView(tabName: category)
                              : ExerciseDisplayScreen(
                                  exerciseType: category,
                                  autoplayEnabled: false,
                                ),
                        ),
                        //const Divider(height: 1, color: Colors.grey),
                        // Journal Toggle Button
                        InkWell(
                          onTap: () {
                            _showJournalBottomSheet(context, category);
                          },
                          child: Container(
                            height: 50, // Height of the container
                            decoration: BoxDecoration(
                              color: Colors.white, // Background color
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    20), // Rounded top-left corner
                                topRight: Radius.circular(
                                    20), // Rounded top-right corner
                              ),
                              border: Border(
                                top: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1), // Top border
                                left: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1), // Left border
                                right: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1), // Right border
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Open Journal",
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.edit,
                                    color: Colors.deepPurple),
                              ],
                            ),
                          ),
                        ),

                        //add devider line
                        const Divider(
                          endIndent: 12,
                          indent: 12,
                          height: 1,
                          color: Color.fromARGB(123, 158, 158, 158),
                        ),
                      ],
                    );
                  }),
                  // Add a separate screen for "+" tab
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add New Tab"),
                      onPressed: () {
                        // Handle adding a new tab logic
                        print("Add new tab clicked");
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
  final String tabName;

  const TabContentEditorView({super.key, required this.tabName});

  @override
  State<TabContentEditorView> createState() => _TabContentEditorViewState();
}

class _TabContentEditorViewState extends State<TabContentEditorView> {
  final TabContentManager _tabManager = TabContentManager();

  late List<TabContentItem> items;

  @override
  void initState() {
    super.initState();
    items = _tabManager.getItems(widget.tabName);
  }

  void _updateOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    _tabManager.reorderItems(widget.tabName, oldIndex, newIndex);
    setState(() {
      items = _tabManager.getItems(widget.tabName);
    });
  }

  void _removeItem(String id) {
    _tabManager.removeItem(widget.tabName, id);
    setState(() {
      items = _tabManager.getItems(widget.tabName);
    });
  }

  void _showAddItemModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
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
                leading:
                    const Icon(Icons.library_books, color: Colors.deepPurple),
                title: const Text('From Library'),
                onTap: () {
                  Navigator.pop(context);
                  _handleAddFromLibrary();
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_box, color: Colors.deepPurple),
                title: const Text('Checklist'),
                onTap: () {
                  Navigator.pop(context);
                  _handleAddChecklist();
                },
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack, color: Colors.deepPurple),
                title: const Text('Audio File'),
                onTap: () {
                  Navigator.pop(context);
                  _handleAddAudio();
                },
              ),
            ],
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

        _tabManager.addItem(widget.tabName, tabItem);
      }

      setState(() {
        items = _tabManager.getItems(widget.tabName);
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
          {'label': 'Task 1', 'done': false},
          {'label': 'Task 2', 'done': false},
        ],
      },
    );
    _tabManager.addItem(widget.tabName, newItem);
    setState(() {
      items = _tabManager.getItems(widget.tabName);
    });
  }

  void _handleAddAudio() {
    // TODO: File picker or local audio reference
    print("Audio tapped");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            itemCount: items.length,
            onReorder: _updateOrder,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                key: ValueKey(item.id),
                title: Text(item.title),
                subtitle: Text(item.type.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeItem(item.id),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Elements'),
            onPressed: () {
              _showAddItemModal(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              //backgroundColor: Colors.deepPurple,
            ),
          ),
        ),
      ],
    );
  }
}
