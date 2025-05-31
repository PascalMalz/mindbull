// Filename: services/favorite_service.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../api/favorite_api.dart';

class FavoriteService {
  static final Box _box = Hive.box('favorites');
  static final FavoriteApi _api = FavoriteApi();

  /// Returns whether an item is currently favorited
  static bool isFavorited(String objectId) {
    return _box.get(objectId, defaultValue: false);
  }

  /// Returns the current favorite count from local cache
  static int getFavoriteCount(String objectId) {
    return _box.get('${objectId}_count', defaultValue: 0);
  }

  /// Toggle favorite: local + API + sync
  static Future<void> toggleFavorite({
    required BuildContext context,
    required String objectId,
    required String contentType,
  }) async {
    final current = isFavorited(objectId);
    final nowFavorite = !current;

    _box.put(objectId, nowFavorite);
    final countKey = '${objectId}_count';
    final oldCount = getFavoriteCount(objectId);
    final optimisticCount = nowFavorite
        ? oldCount + 1
        : (oldCount - 1).clamp(0, double.infinity).toInt();
    _box.put(countKey, optimisticCount);

    try {
      final response = await _api.toggleFavorite(
        objectId: objectId,
        contentType: contentType,
      );

      if (response.containsKey('favorited')) {
        _box.put(objectId, response['favorited']);
      }

      if (response.containsKey('total_favorites')) {
        _box.put('${objectId}_count', response['total_favorites']);
      }
    } catch (e) {
      print("Favorite toggle failed: $e");
      _box.put(objectId, current); // revert
    }
  }

  /// Syncs with server to ensure correct state and count
  static Future<bool> syncFavoriteStatus({
    required BuildContext context,
    required String objectId,
    required String contentType,
  }) async {
    try {
      final response = await _api.getFavoriteStatus(
        objectId: objectId,
        contentType: contentType,
      );

      if (response.containsKey('favorited')) {
        _box.put(objectId, response['favorited']);
      }

      if (response.containsKey('total_favorites')) {
        _box.put('${objectId}_count', response['total_favorites']);
      }

      return true;
    } catch (e) {
      print("Sync failed: $e");
      return false;
    }
  }
}
