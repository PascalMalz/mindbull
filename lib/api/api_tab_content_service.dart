// Filename: api_tab_content_service.dart

import 'package:dio/dio.dart';
import 'package:mindbull/models/tab_content_link.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../api/token_handler.dart';
import '../main.dart';

class ApiTabContentService {
  static final Dio dio = Dio();
  final TokenHandler tokenApiKeeper = getIt<TokenHandler>();

  Future<List<TabContentLink>> fetchTabContentLinks(String tabId) async {
    try {
      final String accessToken = await tokenApiKeeper.getAccessToken();
      const String baseUrl = 'https://neurotune.de/api/tabs/tab-content-links/';

      final response = await dio.get(
        baseUrl,
        queryParameters: {'tab': tabId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      // Save to file for debugging
      Directory docDir = await getApplicationDocumentsDirectory();
      String path = '${docDir.path}/response_tab_content_links.txt';
      File file = File(path);
      await file.writeAsString(response.data.toString(), mode: FileMode.write);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .map((item) =>
                  TabContentLink.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          print('Unexpected data format');
          return [];
        }
      } else {
        throw Exception(
            'Failed to load tab content links, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchTabContentLinks: $e');
      return [];
    }
  }
}
