// lib/services/api_service.dart
import 'dart:convert';
import 'dart:typed_data'; // Required for Uint8List - Keep if you use it directly beyond what foundation re-exports
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
      final response = await http.get(
        url,
        headers: {'accept': 'application/json'},
      );
      return _processResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('ApiService GET Error for $url: $e');
      }
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

  dynamic _processResponse(http.Response response) {
    if (kDebugMode) {
      print(
        'ApiService Response Status: ${response.statusCode} for ${response.request?.url}',
      );
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
        return response.bodyBytes; // For non-JSON (e.g. audio bytes)
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

  Future<Uint8List> askAiWithAudioFile(String filePath) async {
    final url = Uri.parse('$baseUrl/art/askai');
    if (kDebugMode) {
      print('ApiService POST (askAiWithAudioFile): $url with file $filePath');
    }
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath('audio_file', filePath),
    );

    return _sendAskAiRequest(request);
  }

  Future<Uint8List> askAiWithAudioBytes(
    Uint8List audioBytes,
    String filename,
  ) async {
    final url = Uri.parse('$baseUrl/art/askai');
    if (kDebugMode) {
      print(
        'ApiService POST (askAiWithAudioBytes): $url with bytes (filename: $filename)',
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
    return _sendAskAiRequest(request);
  }

  Future<Uint8List> _sendAskAiRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('ApiService askAi Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        if (kDebugMode) {
          print('ApiService askAi Error Body: ${response.body}');
        }
        throw ApiException(
          'Failed to get AI response: ${response.reasonPhrase} (Status: ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('ApiService askAi Exception: $e');
      }
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

  Future<Map<String, dynamic>> fetchPictureOfTheDay(String? artworkId) async {
    final String endpoint = artworkId != null && artworkId.isNotEmpty
        ? 'art/get_picture_details/?id=$artworkId'
        : 'art/get_picture_details';
    final dynamic responseData = await get(endpoint);
    if (responseData is Map<String, dynamic>) {
      return responseData;
    } else if (responseData is Uint8List) {
      try {
        final decodedBody = utf8.decode(responseData);
        return json.decode(decodedBody) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException("Failed to parse picture of the day response: $e");
      }
    }
    throw ApiException("Unexpected response type for picture of the day.");
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
    } else if (responseData is Uint8List) {
      try {
        final decodedBody = utf8.decode(responseData);
        final jsonList = json.decode(decodedBody) as List;
        return jsonList.cast<Map<String, dynamic>>();
      } catch (e) {
        if (kDebugMode) {
          print("Error decoding collections response: $e. Body: ");
        }
        return [];
      }
    }
    if (kDebugMode) {
      print(
        "ApiService fetchArtworksFromCollections: Unexpected response format. Data: ${responseData.runtimeType}",
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
    final dynamic responseData = await get(
      'art/search',
      queryParams: queryParams,
    );

    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    } else if (responseData is Uint8List) {
      try {
        final decodedBody = utf8.decode(responseData);
        final jsonList = json.decode(decodedBody) as List;
        return jsonList.cast<Map<String, dynamic>>();
      } catch (e) {
        if (kDebugMode) {
          print("Error decoding search response: $e. Body:");
        }
        return [];
      }
    }
    if (kDebugMode) {
      print(
        "ApiService searchArtworks: Unexpected response format. Data: ${responseData.runtimeType}",
      );
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchGalleryInfo(String galleryId) async {
    final dynamic responseData = await get('art/galleries/$galleryId/info');
    if (responseData is Map<String, dynamic>) {
      return responseData;
    } else if (responseData is Uint8List) {
      try {
        final decodedBody = utf8.decode(responseData);
        return json.decode(decodedBody) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException("Failed to parse gallery info: $e");
      }
    }
    throw ApiException("Unexpected response type for gallery info.");
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
    } else if (responseData is Uint8List) {
      try {
        final decodedBody = utf8.decode(responseData);
        final jsonList = json.decode(decodedBody) as List;
        return jsonList.cast<Map<String, dynamic>>();
      } catch (e) {
        if (kDebugMode) {
          print("Error decoding galleries response: $e. Body: ");
        }
        return [];
      }
    }
    if (kDebugMode) {
      print(
        "ApiService fetchGalleries: Unexpected response format. Data: ${responseData.runtimeType}",
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
    } else if (responseData is Uint8List) {
      try {
        final decodedBody = utf8.decode(responseData);
        final jsonList = json.decode(decodedBody) as List;
        return jsonList.cast<Map<String, dynamic>>();
      } catch (e) {
        if (kDebugMode) {
          print("Error decoding artworks by gallery response: $e. Body: ");
        }
        return [];
      }
    }
    if (kDebugMode) {
      print(
        "ApiService fetchArtworksByGalleryId: Unexpected response format for gallery $galleryId. Data: ${responseData.runtimeType}",
      );
    }
    return [];
  }
}
