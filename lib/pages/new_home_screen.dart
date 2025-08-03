/* // What this code does:
// This code creates a screen with a top menu, a horizontal list of profile pictures, a vertical list of music cards,
// and a bottom navigation menu with five icons.

// Filename: home_screen.dart
//todo when I go back to home the wrong menu icon is highlighted.
//todo don't always load the feed when it was already fetched from API...
//todo how to fix issue that when the app is reinitialized the homeScreen is grasping the empty user and shows even if a user is logged in no profile pic ect.
//todo when user is deleted you cannot logout or login.
//todo load only first posts. To save performance
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:mindbull/pages/post/post_screen_composition.dart';
import 'package:mindbull/pages/post/posts_audio_image_display_screen.dart';
import 'package:mindbull/widgets/common_bottom_navigation_bar.dart';

import '../api/api_follow_user.dart';
import '../api/api_list_composition_post_service.dart';
import '../models/user.dart';
import '../provider/auth_provider.dart';
import '../provider/user_data_provider.dart';
import 'goals_standalone.dart';
import 'intro.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late UserDataProvider userDataProvider;
  late List<dynamic> followers = [
    {
      "id": "6bb99c3c-a411-46a8-a571-fefe49015e52",
      "username": "pascal_malz",
      "email": "callemalz@gmail.com",
      "profile_picture_url":
          "https://neurotune.de/media/profile_pics/275bed54-e792-41ba-8966-6951cacb7a6a.jpg",
      "followers_count": 1,
      "following_count": 1
    },
    {
      "id": "6468dd6a-6ad6-4892-9f1b-9d9dd65da59d",
      "username": "pascalmalz",
      "email": "callemalz@googlemail.com",
      "profile_picture_url":
          "https://neurotune.de/media/profile_pics/a36ddc22-0428-4c10-8ee4-bd06807ebb94.jpg",
      "followers_count": 1,
      "following_count": 1
    }
  ];
  bool _isLoading = true;

  Future<void> fetchFollowing() async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final user = userDataProvider.currentUser;
    final userId = user?.id;

    if (userId == null) {
      print("User ID is null, cannot fetch followers.");
      return;
    }

    final ApiFollowUser apiFollowUser = GetIt.instance<ApiFollowUser>();

    try {
      final List<dynamic> followersList =
          await apiFollowUser.fetchFollowersList(userId);
      print("followersList: $followersList");
      setState(() {
        followers = followersList;
        _isLoading = false;
      });
    } catch (error) {
      print("Error fetching followers: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    print('home page initializing');
    super.initState();
    // Wait for user data to be loaded before fetching followers
    Provider.of<UserDataProvider>(context, listen: false).addListener(() {
      if (Provider.of<UserDataProvider>(context, listen: false).currentUser !=
          null) {
        fetchFollowing();
      }
    });
  }

  @override
  didChangeDependencies() {
    userDataProvider = Provider.of<UserDataProvider>(context);
    print(
        'HomeScreen: userDataProvider.user?.username: ${userDataProvider.currentUser?.username}');
  }

  ImageProvider? _profileImage;
  final bool _autoplayEnabled = false;

  AppBar buildAppBar(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final username = userDataProvider.currentUser?.username ?? 'Not Logged In';

    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.deepPurple),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.deepPurple,
            ),
            onPressed: () {},
          ),
          // Expanded widget allows the title text to take the remaining space and center itself.
          const Expanded(
            child: Text(
              'Explore Mindset Compositions',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = userDataProvider.currentUser;
    String? userId = user?.id;

    return CommonBottomNavigationBar(
      currentIndex: 0,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: buildAppBar(context),
        endDrawer: buildRightBar(),
        //backgroundColor: Colors.grey.shade900,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: 91,
                  ),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PostsAudioImageDisplayScreen(
                                      autoplayEnabled:
                                          false, // Or dynamically set based on user preferences
                                      userId:
                                          userId, // Pass the current or specified user's ID)),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 80,
                                height: 50,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                // Adjust padding as needed
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  // Use the minimum space that's needed by children
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // Center the items in the row
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 1),
                                    // Space between text and icon, adjust as needed
                                    Text(
                                      'Post',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: followers.length,
                                itemBuilder: (context, index) {
                                  final followingUser = followers[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PostsAudioImageDisplayScreen(
                                              userId: followingUser['id'],
                                              autoplayEnabled: false,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.deepPurple,
                                        radius: 25,
                                        backgroundImage: NetworkImage(
                                            followingUser[
                                                'profile_picture_url']),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 5,
                        color: Colors.white,
                      ),
                      // Profile list
                      Container(
                        color: Colors.white,
                        height: 36,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            Stack(alignment: Alignment.bottomCenter, children: [
                              Container(
                                height: 36,
                                width: 128,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomLeft,
                                height: 34,
                                width: 124,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CompositionPostPage()),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero),
                                    child: Text(
                                      'Affirmations',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(
                              width: 2,
                            ),
                            Stack(alignment: Alignment.bottomCenter, children: [
                              Container(
                                height: 36,
                                width: 128,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomLeft,
                                height: 34,
                                width: 124,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {
                                      APIListCompositionPostService
                                          .fetchPosts();
                                    },
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero),
                                    child: Text(
                                      'Mixed Content',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(
                              width: 2,
                            ),
                            Stack(alignment: Alignment.bottomCenter, children: [
                              Container(
                                height: 36,
                                width: 128,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomLeft,
                                height: 34,
                                width: 124,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CompositionPostPage()),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero),
                                    child: Text(
                                      'Single Audios',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 9,
                color: Colors.black,
              ),
              Expanded(
/*                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 1),
                      right: BorderSide(color: Colors.white, width: 1),
                      left: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),*/
                child: PostsAudioImageDisplayScreen(
                    autoplayEnabled: _autoplayEnabled),
              ),
              /*ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return MusicCard( );
                  },
                ),*/
            ],
          ),
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
 */
