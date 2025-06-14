// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return "ApiException: $message (Status Code: $statusCode)";
  }
}

class ApiService {
  static String baseUrl =
      "https://34.56.10.55"; // Or your appropriate IP for emulator/device

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    print(endpoint);
    final Uri url = Uri.parse(
      '$baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);
    if (kDebugMode) {
      print('ApiService GET: $url');
    }
    try {
      final response = await http.get(
        url,
        headers: {'accept': 'application/json'},
      );
      return _processResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('ApiService GET Error for $url: $e');
      }
      if (e.toString().contains('Connection refused')) {
        throw ApiException(
          'Failed to connect to the server. Is it running at $baseUrl?',
        );
      }
      throw ApiException('Network error while fetching $endpoint: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (kDebugMode) {
      print(
        'ApiService Response Status: ${response.statusCode} for ${response.request?.url}',
      );
    }
    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson = json.decode(response.body);
        return responseJson;
      case 400:
        throw ApiException(
          'Bad request: ${response.body}',
          statusCode: response.statusCode,
        );
      case 401:
      case 403:
        throw ApiException(
          'Unauthorized or Forbidden: ${response.body}',
          statusCode: response.statusCode,
        );
      case 404:
        throw ApiException(
          'Resource not found: ${response.request?.url.path}',
          statusCode: response.statusCode,
        );
      default:
        throw ApiException(
          'Error: ${response.statusCode}, Body: ${response.body}',
          statusCode: response.statusCode,
        );
    }
  }

  Future<Map<String, dynamic>> fetchPictureOfTheDay(String? artwrokId) async {
    final String endpoint = artwrokId != null && artwrokId.isNotEmpty
        ? 'get_picture_details/?id=$artwrokId'
        : 'get_picture_details';
    final Map<String, dynamic> responseData =
        await get(endpoint) as Map<String, dynamic>;
    return responseData;
  }

  Future<List<Map<String, dynamic>>> fetchArtworksFromCollections({
    Map<String, String>? filters,
    int limit = 10,
    int skip = 0,
  }) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
      'skip': skip.toString(),
      ...?filters,
    };

    final dynamic responseData = await get(
      'collections',
      queryParams: queryParams,
    );

    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    } else if (responseData is Map<String, dynamic> &&
        responseData.containsKey('artworks') &&
        responseData['artworks'] is List) {
      return (responseData['artworks'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } else if (responseData is Map<String, dynamic> &&
        responseData.containsKey('items') &&
        responseData['items'] is List) {
      return (responseData['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    }
    if (kDebugMode) {
      print(
        "ApiService fetchArtworksFromCollections: Unexpected response format.",
      );
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> searchArtworks({
    required String query,
    int limit = 10,
    int skip = 0,
  }) async {
    final Map<String, String> queryParams = {
      'q': query,
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    final dynamic responseData = await get('search', queryParams: queryParams);

    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    } else if (responseData is Map<String, dynamic> &&
        responseData.containsKey('results') &&
        responseData['results'] is List) {
      return (responseData['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } else if (responseData is Map<String, dynamic> &&
        responseData.containsKey('items') &&
        responseData['items'] is List) {
      return (responseData['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    }
    if (kDebugMode) {
      print("ApiService searchArtworks: Unexpected response format.");
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchGalleryInfo(String galleryId) async {
    // This endpoint was defined but not used yet in the previous steps.
    // If you need it, ensure it's correctly implemented in your backend.
    final Map<String, dynamic> responseData =
        await get('galleries/$galleryId/info') as Map<String, dynamic>;
    return responseData;
  }

  Future<List<Map<String, dynamic>>> fetchGalleries({
    int limit = 10,
    int skip = 0,
  }) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    final dynamic responseData = await get(
      'galleries',
      queryParams: queryParams,
    );

    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    }
    if (kDebugMode) {
      print("ApiService fetchGalleries: Unexpected response format.");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchArtworksByGalleryId({
    required String galleryId,
    int limit = 10,
    int skip = 0,
  }) async {
    final Map<String, String> queryParams = {
      'gallery_id': galleryId,
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    final dynamic responseData = await get(
      'artworks_by_gallery',
      queryParams: queryParams,
    );

    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    }
    if (kDebugMode) {
      print(
        "ApiService fetchArtworksByGalleryId: Unexpected response format for gallery $galleryId.",
      );
    }
    return [];
  }
}
