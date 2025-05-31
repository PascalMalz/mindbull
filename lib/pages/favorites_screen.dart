// Filename: favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:mindbull/models/post.dart';
import 'package:mindbull/widgets/exercise_card.dart';
import '../api/favorite_api.dart';
import '../models/exercise.dart';
import '../widgets/post_card.dart'; // For posts

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String selectedFilter = 'All';
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  final filters = ['All', 'exercise', 'audio', 'post'];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final results = await FavoriteApi().getUserFavorites(); // Add this method
      setState(() {
        favorites = results;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading favorites: $e");
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get filteredFavorites {
    if (selectedFilter == 'All') return favorites;
    return favorites.where((f) => f['content_type'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Favorites")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: selectedFilter == filter,
                          onSelected: (_) {
                            setState(() => selectedFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                      itemCount: filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final item = filteredFavorites[index];
                        final type = item['content_type'];
                        final data = item['data'];

                        if (type == 'exercise') {
                          return ExerciseCardWithFavorite(
                            exercise: Exercise.fromJson(data),
                            autoplayEnabled: false,
                          );
                        } else if (type == 'post') {
                          return PostCard(
                            post: Post.fromJson(data),
                            autoplayEnabled: false,
                          );
                        } else {
                          return ListTile(
                            title: Text('Unsupported favorite type: $type'),
                          );
                        }
                      }),
                ),
              ],
            ),
    );
  }
}
