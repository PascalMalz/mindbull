// Filename: api/favorite_api.dart
//
// Handles favoriting and unfavoriting of any content type via the generic Django endpoint.

import 'package:dio/dio.dart';
import 'package:mindbull/api/token_handler.dart';
import 'package:mindbull/main.dart'; // for getIt

class FavoriteApi {
  final Dio _dio = Dio();
  final TokenHandler _tokenHandler = getIt<TokenHandler>();

  // Toggle favorite status (generic for any content type)
  Future<Map<String, dynamic>> toggleFavorite({
    required String objectId,
    required String contentType,
  }) async {
    final String authToken = await _tokenHandler.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/favorites/toggle/';

    try {
      final Response response = await _dio.post(
        apiUrl,
        data: {
          'object_id': objectId,
          'content_type': contentType,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } catch (e) {
      print("toggleFavorite error: $e");
      rethrow;
    }
  }

  // Get current favorite status and count
  Future<Map<String, dynamic>> getFavoriteStatus({
    required String objectId,
    required String contentType,
  }) async {
    final String authToken = await _tokenHandler.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/favorites/status/';

    try {
      final Response response = await _dio.get(
        apiUrl,
        queryParameters: {
          'object_id': objectId,
          'content_type': contentType,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } catch (e) {
      print("getFavoriteStatus error: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserFavorites() async {
    final String authToken = await _tokenHandler.getAccessToken();

    final response = await _dio.get(
      'https://neurotune.de/api/favorites/user/',
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    print(response.data);
    return List<Map<String, dynamic>>.from(response.data);
  }
}
