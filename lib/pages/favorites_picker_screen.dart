//Filename: favorites_picker_screen.dart
//This screen shows favorites with checkboxes for multi-select.

import 'package:flutter/material.dart';
import 'package:mindbull/models/exercise.dart';
import 'package:mindbull/models/post.dart';
import 'package:mindbull/widgets/exercise_card.dart';
import 'package:mindbull/widgets/post_card.dart';
import '../api/favorite_api.dart';

class FavoritesPickerScreen extends StatefulWidget {
  const FavoritesPickerScreen({super.key});

  @override
  State<FavoritesPickerScreen> createState() => _FavoritesPickerScreenState();
}

class _FavoritesPickerScreenState extends State<FavoritesPickerScreen> {
  List<Map<String, dynamic>> favorites = [];
  Set<int> selectedIndexes = {};
  bool isLoading = true;
  String selectedFilter = 'All';

  final filters = [
    {'label': 'All', 'value': 'All'},
    {'label': 'Exercise', 'value': 'exercise'},
    {'label': 'Audio', 'value': 'audio'},
    {'label': 'Post', 'value': 'post'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final result = await FavoriteApi().getUserFavorites();
      setState(() {
        favorites = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
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
      appBar: AppBar(title: const Text("Select Favorites")),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: selectedIndexes.isEmpty
              ? null
              : () {
                  final selectedItems =
                      selectedIndexes.map((i) => filteredFavorites[i]).toList();
                  Navigator.pop(context, selectedItems);
                },
          icon: const Icon(Icons.add),
          label: const Text("Add Selected"),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: filters.map((filter) {
                      final isSelected = selectedFilter == filter['value'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: ChoiceChip(
                          label: Text(filter['label']!),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedFilter = filter['value']!;
                              selectedIndexes.clear();
                            });
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
                      final isSelected = selectedIndexes.contains(index);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) {
                          setState(() {
                            isSelected
                                ? selectedIndexes.remove(index)
                                : selectedIndexes.add(index);
                          });
                        },
                        title: type == 'exercise'
                            ? ExerciseCardWithFavorite(
                                exercise: Exercise.fromJson(data),
                                autoplayEnabled: false,
                              )
                            : type == 'post'
                                ? PostCard(
                                    post: Post.fromJson(data),
                                    autoplayEnabled: false,
                                  )
                                : Text('Unsupported: $type'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
