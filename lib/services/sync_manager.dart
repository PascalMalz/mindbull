// SyncManager handles two-way syncing of tabs and their content with the backend.
// Includes pulling updated tabs from server and pushing locally changed data.

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mindbull/api/token_handler.dart';
import 'package:mindbull/main.dart'; // for getIt

class SyncManager {
  final Dio _dio = Dio();
  final TokenHandler _tokenHandler = getIt<TokenHandler>();

  final tabsBox = Hive.box('tabs');
  final contentsBox = Hive.box('tab_contents');
  final metaBox = Hive.box('sync_meta');

  // 🔁 Pull server updates since last sync
  Future<void> syncTabsFromServer() async {
    final String authToken = await _tokenHandler.getAccessToken();
    final String lastSync =
        metaBox.get('last_sync_time') ?? '1970-01-01T00:00:00Z';
    final String apiUrl = 'https://neurotune.de/api/sync/tabs/';

    try {
      final response = await _dio.get(
        apiUrl,
        queryParameters: {'updated_since': lastSync},
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> tabs = response.data['tabs'];
      final String newServerTime = response.data['server_time'];

      for (var tab in tabs) {
        tabsBox.put(tab['tab_id'], tab);
        if (tab['contents'] != null) {
          for (var item in tab['contents']) {
            contentsBox.put(item['id'], item);
          }
        }
      }

      metaBox.put('last_sync_time', newServerTime);
    } catch (e) {
      print("Sync (GET) failed: $e");
      rethrow;
    }
  }

  // 🔼 Push local changes to server (for dirty tabs and contents)
  Future<void> uploadDirtyTabsToServer() async {
    final String authToken = await _tokenHandler.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/sync/upload/';

    try {
      final dirtyTabs =
          tabsBox.values.where((t) => t['is_dirty'] == true).toList();

      final dirtyContents =
          contentsBox.values.where((c) => c['is_dirty'] == true).toList();

      final payload = {
        'tabs': dirtyTabs,
        'contents': dirtyContents,
      };

      final response = await _dio.post(
        apiUrl,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Mark as synced
      for (var tab in dirtyTabs) {
        tab['is_dirty'] = false;
        tabsBox.put(tab['tab_id'], tab);
      }
      for (var item in dirtyContents) {
        item['is_dirty'] = false;
        contentsBox.put(item['id'], item);
      }
    } catch (e) {
      print("Sync (POST) failed: $e");
      rethrow;
    }
  }
}
