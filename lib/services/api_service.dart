// lib/services/api_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:hack_front/models/artwork_model.dart'; // Assuming you want to keep this for askAi methods
import 'package:hack_front/providers/auth_provider.dart'; // For token access
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
  static String baseUrl = "https://artatlas-995532374345.us-central1.run.app";
  final AuthProvider authProvider;
  ApiService({required this.authProvider});

  Future<Map<String, String>> _getHeaders([
    bool forceTokenRefresh = false,
  ]) async {
    final Map<String, String> headers = {
      'accept': 'application/json',
      // 'Content-Type': 'application/json', // Set by http.MultipartRequest or http.post for body
    };
    final String? token = await authProvider.getIdToken(forceTokenRefresh);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      if (kDebugMode) {
        print("ApiService: No ID token available for request header.");
      }
    }
    return headers;
  }

  // Centralized response processing from your version
  dynamic _processResponse(http.Response response) {
    if (kDebugMode) {
      print(
        'ApiService Response Status: ${response.statusCode} for ${response.request?.url}',
      );
      // if (response.statusCode >= 400) print('ApiService Error Body: ${response.body}');
    }
    switch (response.statusCode) {
      case 200:
      case 201:
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          try {
            var responseJson = json.decode(utf8.decode(response.bodyBytes));
            return responseJson;
          } catch (e) {
            if (kDebugMode) {
              print(
                "JSON Decode Error: ${e.toString()} \nBody: ${response.body}",
              );
            }
            throw ApiException(
              "Failed to parse JSON response.",
              statusCode: response.statusCode,
            );
          }
        }
        return response
            .bodyBytes; // For non-JSON (e.g. audio bytes from askAi or proxied image)
      case 400:
        throw ApiException(
          'Bad request: ${response.body}',
          statusCode: response.statusCode,
        );
      case 401: // Handled by _handle401AndRetry for GET/DELETE, but keep for others
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

  Future<dynamic> _handle401AndRetry(
    Future<http.Response> Function(Map<String, String> headers) requestExecutor,
  ) async {
    var headers = await _getHeaders();
    var response = await requestExecutor(headers);

    if (response.statusCode == 401) {
      if (kDebugMode) {
        print(
          "ApiService: Received 401 Unauthorized. Attempting token refresh.",
        );
      }
      final String? newToken = await authProvider.getIdToken(
        true,
      ); // Force refresh
      if (newToken != null) {
        headers = await _getHeaders(); // Get headers with the new token
        if (kDebugMode) {
          print("ApiService: Token refreshed. Retrying original request.");
        }
        response = await requestExecutor(headers); // Retry with new headers
        return _processResponse(
          response,
        ); // Process potentially successful retried response
      } else {
        // Token refresh failed or no token, sign out (AuthProvider handles notifyListeners)
        await authProvider.signOut();
        throw ApiException(
          "Session expired. Please log in again.",
          statusCode: 401,
        );
      }
    }
    return _processResponse(response);
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final Uri url = Uri.parse(
      '$baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);
    if (kDebugMode) {
      print('ApiService GET: $url');
    }

    try {
      return await _handle401AndRetry((headers) async {
        return http.get(url, headers: headers);
      });
    } catch (e) {
      if (kDebugMode) {
        print('ApiService GET Error for $url: $e');
      }
      if (e is ApiException) rethrow; // Already an ApiException
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw ApiException(
          'Failed to connect to the server. Is it running at $baseUrl and accessible?',
        );
      }
      throw ApiException('Network error while fetching $endpoint: $e');
    }
  }

  Future<Uint8List> _sendAskAiRequest(http.MultipartRequest request) async {
    try {
      final String? token = await authProvider.getIdToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['accept'] =
          'application/octet-stream'; // Backend expects this for response

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print(
          'ApiService askAi Multipart Response Status: ${response.statusCode}',
        );
        if (response.statusCode != 200) {
          print('ApiService askAi Multipart Error Body: ${response.body}');
        }
      }

      // Specific 401 handling for multipart - might be complex to retry transparently
      if (response.statusCode == 401) {
        final String? newToken = await authProvider.getIdToken(true);
        if (newToken != null) {
          // You might want to update request.headers['Authorization'] = 'Bearer $newToken';
          // and then re-send 'request' IF http.MultipartRequest can be resent.
          // Often, streams can only be read once. So, a higher-level retry is safer.
          throw ApiException(
            "Token refreshed. Please try 'Ask AI' again.",
            statusCode: 401,
          );
        } else {
          await authProvider.signOut();
          throw ApiException(
            "Session expired. Please log in again.",
            statusCode: 401,
          );
        }
      }

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        // Use _processResponse for consistent error throwing from multipart as well
        // This might not be ideal if _processResponse expects JSON errors and multipart returns different error structure
        // For now, let's keep your specific ApiException for multipart errors.
        throw ApiException(
          'Failed to get AI response: ${response.reasonPhrase} (Status: ${response.statusCode}), Body: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('ApiService askAi Exception: $e');
      }
      if (e is ApiException) rethrow;
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw ApiException(
          'Failed to connect to the server for Ask AI. Is it running at $baseUrl and accessible?',
        );
      }
      throw ApiException('Network error during AI audio request: $e');
    }
  }

  // Using your updated methods with Artwork model directly
  Future<Uint8List> askAiWithAudioFile({
    required String filePath,
    required Artwork artwork,
  }) async {
    final url = Uri.parse(
      '$baseUrl/art/askai',
    ); // Not used directly, request object builds it
    if (kDebugMode) {
      print(
        'ApiService POST (askAiWithAudioFile): $url with file $filePath and data ${artwork.toJson()}',
      );
    }
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath('audio_file', filePath),
    );
    request.fields['artwork_data'] = json.encode(artwork.toJson());
    return _sendAskAiRequest(request);
  }

  Future<Uint8List> askAiWithAudioBytes({
    required Uint8List audioBytes,
    required String filename,
    required Artwork artwork,
  }) async {
    final url = Uri.parse('$baseUrl/art/askai'); // Not used directly
    if (kDebugMode) {
      print(
        'ApiService POST (askAiWithAudioBytes): $url with bytes (filename: $filename) and data ${artwork.toJson()}',
      );
    }
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      http.MultipartFile.fromBytes(
        'audio_file',
        audioBytes,
        filename: filename,
      ),
    );
    request.fields['artwork_data'] = json.encode(artwork.toJson());
    return _sendAskAiRequest(request);
  }

  // Standard GET methods now use the token-aware `get()` method
  Future<Map<String, dynamic>> fetchPictureOfTheDay(String? artworkId) async {
    final String endpoint = artworkId != null && artworkId.isNotEmpty
        ? 'art/get_picture_details/?id=$artworkId'
        : 'art/get_picture_details';
    // `get` method will handle headers and potential 401 retry
    return await get(endpoint) as Map<String, dynamic>;
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
      'art/collections',
      queryParams: queryParams,
    );
    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    }
    // Removed Uint8List check here as GET should already be processed by _processResponse
    if (kDebugMode) {
      print(
        "ApiService fetchArtworksFromCollections: Unexpected response format after processing. Data: ${responseData.runtimeType}",
      );
    }
    return []; // Should ideally not happen if _processResponse works
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
    final dynamic responseData = await get(
      'art/search',
      queryParams: queryParams,
    );
    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    }
    if (kDebugMode) {
      print(
        "ApiService searchArtworks: Unexpected response format after processing. Data: ${responseData.runtimeType}",
      );
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchGalleryInfo(String galleryId) async {
    return await get('art/galleries/$galleryId/info') as Map<String, dynamic>;
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
      'art/galleries',
      queryParams: queryParams,
    );
    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    }
    if (kDebugMode) {
      print(
        "ApiService fetchGalleries: Unexpected response format after processing. Data: ${responseData.runtimeType}",
      );
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
      'art/artworks_by_gallery',
      queryParams: queryParams,
    );
    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    }
    if (kDebugMode) {
      print(
        "ApiService fetchArtworksByGalleryId: Unexpected response format after processing for gallery $galleryId. Data: ${responseData.runtimeType}",
      );
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchSimilarArtworks({
    required String artworkId,
    int limit = 10,
  }) async {
    final Map<String, String> queryParams = {
      'artwork_id': artworkId,
      'limit': limit.toString(),
    };
    final dynamic responseData = await get(
      'art/get_similar_artworks',
      queryParams: queryParams,
    );
    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    }
    if (kDebugMode) {
      print(
        "ApiService fetchSimilarArtworks: Unexpected response format after processing for artwork $artworkId. Data: ${responseData.runtimeType}",
      );
    }
    return [];
  }
}