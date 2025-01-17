import 'package:flutter/material.dart';
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
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
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
                leading: const Icon(Icons.auto_graph),
                title: const Text('Goals'),
                onTap: () {
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
                  // Implement notification settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Data Protection'),
                onTap: () {
                  // Implement data protection settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: const Text('Account'),
                onTap: () {
                  // Implement account settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Implement settings
                },
              ),
              if (user == null)
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Log In'),
                  onTap: () async {
                    await Navigator.pushNamed(
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
                  onTap: () {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    authProvider.logout();
                    Navigator.pop(context);
                  },
                ),
            ],
          );
        },
      ),
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
                          child: ExerciseDisplayScreen(
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
}
