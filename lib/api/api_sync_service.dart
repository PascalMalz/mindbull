import 'package:dio/dio.dart';
import '../api/token_handler.dart';
import '../main.dart';

class ApiSyncService {
  static final Dio dio = Dio();
  final TokenHandler tokenApiKeeper = getIt<TokenHandler>();

  Future<String?> fetchSyncToken() async {
    try {
      final String accessToken = await tokenApiKeeper.getAccessToken();
      const String url = 'https://neurotune.de/api/sync/token/';

      final response = await dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['sync_token'];
        print('🌀 Sync token received: $token');
        return token;
      } else {
        print('⚠️ Failed to fetch sync token, status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception while fetching sync token: $e');
      return null;
    }
  }
}
