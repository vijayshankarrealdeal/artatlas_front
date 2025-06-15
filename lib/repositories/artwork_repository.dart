// lib/repositories/artwork_repository.dart
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/models/gallery_model.dart';
import 'package:hack_front/services/api_service.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class ArtworkRepository {
  final ApiService _apiService;

  ArtworkRepository(this._apiService);

  Future<List<Artwork>> getArtworks({
    String? sortBy,
    String? dateRange,
    String? classification,
    String? artist,
    String? style,
    String? searchQuery,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      List<Map<String, dynamic>> artworkDataList;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (kDebugMode) {
          print(
            "ArtworkRepository: Searching for '$searchQuery', limit: $limit, skip: $skip",
          );
        }
        artworkDataList = await _apiService.searchArtworks(
          query: searchQuery,
          limit: limit,
          skip: skip,
        );
      } else {
        final Map<String, String> filters = {};
        if (sortBy != null &&
            sortBy != 'Sort: By Relevance' &&
            !sortBy.contains(': All'))
          filters['sort'] = sortBy
              .split(': ')
              .last
              .toLowerCase()
              .replaceAll(' ', '_');
        if (dateRange != null &&
            dateRange != 'Date: All' &&
            !dateRange.contains(': All'))
          filters['date'] = dateRange
              .split(': ')
              .last
              .toLowerCase()
              .replaceAll(' ', '_');
        if (classification != null &&
            classification != 'Classifications: All' &&
            !classification.contains(': All'))
          filters['classification'] = classification;
        if (artist != null &&
            artist != 'Artists: All' &&
            !artist.contains(': All'))
          filters['artist'] = artist;
        if (style != null && style != 'Styles: All' && !style.contains(': All'))
          filters['style'] = style;

        if (kDebugMode) {
          print(
            "ArtworkRepository: Fetching collections with filters: $filters, limit: $limit, skip: $skip",
          );
        }
        artworkDataList = await _apiService.fetchArtworksFromCollections(
          filters: filters.isNotEmpty ? filters : null,
          limit: limit,
          skip: skip,
        );
      }

      return artworkDataList.map((data) => Artwork.fromJson(data)).toList();
    } on ApiException catch (e) {
      print("ArtworkRepository Error fetching artworks/searching: $e");
      throw Exception('Failed to load artworks: ${e.message}');
    } catch (e) {
      print(
        "ArtworkRepository Unexpected Error fetching artworks/searching: $e",
      );
      throw Exception('An unexpected error occurred while loading artworks.');
    }
  }

  Future<Artwork?> getPictureOfTheDay(String? artworkId) async {
    try {
      final Map<String, dynamic> data = await _apiService.fetchPictureOfTheDay(
        artworkId,
      );
      return Artwork.fromJson(data);
    } on ApiException catch (e) {
      print("ArtworkRepository PoTD Error: $e");
      return null;

      // Artwork(
      //   id: 'fallback_potd_api_error',
      //   artworkTitle: 'Picture of the Day (Network Error)',
      //   imageUrl:
      //       'https://images.pexels.com/photos/1269968/pexels-photo-1269968.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      //   artistName: 'System',
      //   year: 'N/A',
      //   category: 'Could not connect: ${e.message}',
      // );
    } catch (e) {
      print("ArtworkRepository PoTD Unexpected Error: $e");
      return null;
      // Artwork(
      //   id: 'fallback_potd_unexpected_error',
      //   artworkTitle: 'Picture of the Day (Loading Error)',
      //   imageUrl:
      //       'https://images.pexels.com/photos/753339/pexels-photo-753339.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      //   artistName: 'System',
      //   year: 'N/A',
      //   category: 'An unexpected error occurred.',
      // );
    }
  }

  Future<List<GalleryModel>> getGalleries({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      if (kDebugMode) {
        print(
          "ArtworkRepository: Fetching galleries, limit: $limit, skip: $skip",
        );
      }
      final List<Map<String, dynamic>> galleryDataList = await _apiService
          .fetchGalleries(limit: limit, skip: skip);
      return galleryDataList
          .map((data) => GalleryModel.fromJson(data))
          .toList();
    } on ApiException catch (e) {
      print("ArtworkRepository Error fetching galleries: $e");
      throw Exception('Failed to load galleries: ${e.message}');
    } catch (e) {
      print("ArtworkRepository Unexpected Error fetching galleries: $e");
      throw Exception('An unexpected error occurred while loading galleries.');
    }
  }

  Future<List<Artwork>> getArtworksByGalleryId({
    required String galleryId,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      if (kDebugMode) {
        print(
          "ArtworkRepository: Fetching artworks for gallery ID '$galleryId', limit: $limit, skip: $skip",
        );
      }
      final List<Map<String, dynamic>> artworkDataList = await _apiService
          .fetchArtworksByGalleryId(
            galleryId: galleryId,
            limit: limit,
            skip: skip,
          );
      // Ensure Artwork.fromJson handles the case where 'artworks_id' might be missing
      // and uses '_id' from the artwork data as a fallback for the Artwork's 'id' field.
      return artworkDataList.map((data) => Artwork.fromJson(data)).toList();
    } on ApiException catch (e) {
      print(
        "ArtworkRepository Error fetching artworks for gallery $galleryId: $e",
      );
      throw Exception('Failed to load artworks for gallery: ${e.message}');
    } catch (e) {
      print(
        "ArtworkRepository Unexpected Error fetching artworks for gallery $galleryId: $e",
      );
      throw Exception(
        'An unexpected error occurred while loading artworks for gallery.',
      );
    }
  }
}
