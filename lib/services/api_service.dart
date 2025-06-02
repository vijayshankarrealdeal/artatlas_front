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
      "http://127.0.0.1:8000"; // Or your appropriate IP for emulator/device

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    // Modified to accept queryParams directly
    final Uri url = Uri.parse(
      '$baseUrl/$endpoint',
    ).replace(queryParameters: queryParams); // Use replace for queryParams
    if (kDebugMode) {
      print('ApiService GET: $url');
    }
    try {
      final response = await http.get(
        url,
        headers: {'accept': 'application/json'}, // Default accept header
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
      // Avoid printing very long bodies in production logs
      // if (response.body.length < 1000) print('ApiService Response Body: ${response.body}');
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

  Future<Map<String, dynamic>> fetchPictureOfTheDay() async {
    final Map<String, dynamic> responseData =
        await get('picture_of_the_day') as Map<String, dynamic>;
    return responseData;
  }

  // Updated to use the /collections endpoint and handle filters
  Future<List<Map<String, dynamic>>> fetchArtworksFromCollections({
    Map<String, String>?
    filters, // User-selected filters (sort, date, classification etc.)
    int limit = 10,
    int skip = 0,
  }) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
      'skip': skip.toString(),
      ...?filters, // Spread the filter parameters
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
      // Common pattern for paginated results: {"items": [...], "total": X, "page": Y, "size": Z}
      return (responseData['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    }
    if (kDebugMode) {
      print(
        "ApiService fetchArtworksFromCollections: Unexpected response format. Expected List or Map with 'items' or 'artworks' list.",
      );
    }
    return [];
  }

  // New method for searching artworks
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
      print(
        "ApiService searchArtworks: Unexpected response format. Expected List or Map with 'results' or 'items' list.",
      );
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchGalleryInfo(String galleryId) async {
    final Map<String, dynamic> responseData =
        await get('galleries/$galleryId/info') as Map<String, dynamic>;
    return responseData;
  }

  // New method to fetch galleries
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
      print(
        "ApiService fetchGalleries: Unexpected response format. Expected List.",
      );
    }
    return [];
  }
}
