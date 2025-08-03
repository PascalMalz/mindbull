// Filename: api/tab_api.dart
//
// Handles fetching of default backend-created tabs for HomeScreenV2.

import 'package:dio/dio.dart';
import 'package:mindbull/api/token_handler.dart';
import 'package:mindbull/main.dart'; // for getIt

class TabApi {
  final Dio _dio = Dio();
  final TokenHandler _tokenHandler = getIt<TokenHandler>();

  // Fetch default backend-defined tabs (e.g., "Daily", "Affirmation", etc.)
  Future<List<Map<String, dynamic>>> fetchDefaultTabs() async {
    final String authToken = await _tokenHandler.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/tabs/default/';

    try {
      final Response response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> tabs = response.data['tabs'];
      print("Loaded tabs");
      print(tabs);
      return List<Map<String, dynamic>>.from(tabs);
    } catch (e) {
      print("fetchDefaultTabs error: $e");
      rethrow;
    }
  }
}
