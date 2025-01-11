import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindbull/pages/goals_standalone.dart';
import 'package:mindbull/pages/intro.dart';
import 'package:mindbull/provider/auth_provider.dart';
import '../pages/exercise_display_screen.dart';
import '../provider/user_data_provider.dart';
import '../widgets/common_bottom_navigation_bar.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  _HomeScreenV2State createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _journalTabController;

  final List<String> categories = [
    'Affirmation',
    'Visualization',
    'Reframing',
    'Meditation',
    'Gratitude',
    'Motivation',
    'Acceptance',
  ];

  String globalJournal = ""; // Global journal entry
  Map<String, String> tabSpecificJournals = {}; // Tab-specific journal entries

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length + 1, vsync: this);
    _journalTabController = TabController(length: 2, vsync: this);

    // Initialize journal entries
    for (var category in categories) {
      tabSpecificJournals[category] = "";
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _journalTabController.dispose();
    super.dispose();
  }

  AppBar buildAppBar(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final username = userDataProvider.currentUser?.username ?? 'Not Logged In';

    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.deepPurple),
      centerTitle: true,
      title: const Text(
        'Daily Mind Workout',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      ),
      elevation: 0,
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
            // Category Tabs
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
            // Main Content Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ...categories.map((category) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ExerciseDisplayScreen(
                            exerciseType: category,
                            autoplayEnabled: false,
                          ),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        // Journal Tabs (Global and Tab-Specific)
                        Column(
                          children: [
                            TabBar(
                              controller: _journalTabController,
                              labelColor: Colors.deepPurple,
                              unselectedLabelColor: Colors.black,
                              indicatorColor: Colors.deepPurple,
                              tabs: [
                                const Tab(text: "Global Journal"),
                                Tab(text: "Journal for $category"),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 150, // Adjust height as needed
                              child: TabBarView(
                                controller: _journalTabController,
                                children: [
                                  // Global Journal Tab
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: TextField(
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText:
                                            "Log general thoughts or reflections here",
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          globalJournal = value;
                                        });
                                      },
                                      controller: TextEditingController(
                                        text: globalJournal,
                                      ),
                                    ),
                                  ),
                                  // Tab-Specific Journal
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: TextField(
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText:
                                            "What did you learn or want to remember?",
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          tabSpecificJournals[category] = value;
                                        });
                                      },
                                      controller: TextEditingController(
                                        text: tabSpecificJournals[category],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

        String? profilePictureUrl = user?.profilePictureUrl;
        ImageProvider backgroundImage =
            (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                ? NetworkImage(profilePictureUrl) as ImageProvider<Object>
                : const AssetImage('assets/pascalmalz.jpg')
                    as ImageProvider<Object>;

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
              leading: const Icon(
                Icons.auto_graph,
              ),
              title: const Text('Goals'),
              onTap: () {
                // Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GoalsStandalone()),
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
                // Implement logout logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Data Protection'),
              onTap: () {
                // Implement logout logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('Account'),
              onTap: () {
                // Implement logout logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Implement logout logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Print User Data'),
              onTap: () {
                final userDataProvider =
                    Provider.of<UserDataProvider>(context, listen: false);
                print('user name: ${userDataProvider.currentUser?.username}');
                setState(() {});
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
                    setState(() {});
                  }),
          ],
        );
      }),
    );
  }
}
