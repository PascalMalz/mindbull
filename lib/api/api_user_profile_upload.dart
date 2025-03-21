import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mindbull/api/token_handler.dart';

import '../main.dart';

class ApiUserProfileUpload {
  final Dio _dio = Dio();
  final TokenHandler tokenApiKeeper =
      getIt<TokenHandler>(); // Use getIt to get the instance

  Future<String?> uploadImage(File imageFile) async {
    final String authToken = await tokenApiKeeper.getAccessToken();
    const String apiUrl =
        'https://neurotune.de/sum/api/upload-profile-picture/';

    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data', // Change Content-Type
      'Authorization': 'Bearer $authToken',
      // Add any other headers like Authorization if necessary
    };

    try {
      FormData formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'upload.jpg',
        ),
      });

      final Response response = await _dio.post(
        apiUrl,
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return null; // Image uploaded successfully
      } else if (response.statusCode == 400) {
        return 'No image file provided';
      } else if (response.statusCode == 401) {
        return 'Unauthorized'; // Handle unauthorized access if needed
      } else {
        return 'Backend request failed with status code ${response.statusCode}';
      }
    } catch (error) {
      return 'Please try again later.';
      // Uncomment the next line to get more detailed error info during development:
      // return 'Dio error: $error';
    }
  }

  Future<String?> updateBio(String bio) async {
    final String authToken = await tokenApiKeeper.getAccessToken();
    const String apiUrl = 'https://neurotune.de/sum/api/update-bio/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await _dio.post(
        apiUrl,
        data: jsonEncode({'bio': bio}),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return null; // Bio updated successfully
      } else {
        return 'Backend request failed with status code ${response.statusCode}';
      }
    } catch (error) {
      return 'Please try again later.';
      // Uncomment the next line to get more detailed error info during development:
      // return 'Dio error: $error';
    }
  }
}
