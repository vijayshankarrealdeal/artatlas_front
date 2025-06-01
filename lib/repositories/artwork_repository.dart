// lib/repositories/artwork_repository.dart
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/services/api_service.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class ArtworkRepository {
  final ApiService _apiService;

  ArtworkRepository(this._apiService);

  Future<List<Artwork>> getArtworks({
    // Filter parameters from CollectionsProvider
    String? sortBy,
    String? dateRange,
    String? classification,
    String? artist,
    String? style,
    String? searchQuery, // This will now determine if we call search or collections endpoint
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      List<Map<String, dynamic>> artworkDataList;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // If there's a search query, use the search endpoint
        if (kDebugMode) {
          print("ArtworkRepository: Searching for '$searchQuery', limit: $limit, skip: $skip");
        }
        artworkDataList = await _apiService.searchArtworks(
          query: searchQuery,
          limit: limit,
          skip: skip,
        );
      } else {
        // Otherwise, fetch from collections with filters
        final Map<String, String> filters = {};
        // Convert user-friendly filter names to API query parameter values
        // IMPORTANT: Adjust these keys ('sort', 'date', 'classification', etc.)
        // to match EXACTLY what your backend /collections endpoint expects.
        if (sortBy != null && sortBy != 'Sort: By Relevance' && !sortBy.contains(': All')) filters['sort'] = sortBy.split(': ').last.toLowerCase().replaceAll(' ', '_');
        if (dateRange != null && dateRange != 'Date: All' && !dateRange.contains(': All')) filters['date'] = dateRange.split(': ').last.toLowerCase().replaceAll(' ', '_');
        if (classification != null && classification != 'Classifications: All' && !classification.contains(': All')) filters['classification'] = classification;
        if (artist != null && artist != 'Artists: All' && !artist.contains(': All')) filters['artist'] = artist;
        if (style != null && style != 'Styles: All' && !style.contains(': All')) filters['style'] = style;
        
        if (kDebugMode) {
          print("ArtworkRepository: Fetching collections with filters: $filters, limit: $limit, skip: $skip");
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
      // Consider returning an empty list or a custom error state object
      return []; // Return empty on API error
    } catch (e) {
      print("ArtworkRepository Unexpected Error fetching artworks/searching: $e");
      return []; // Return empty on unexpected error
    }
  }

  Future<Artwork> getPictureOfTheDay() async {
    try {
      final Map<String, dynamic> data = await _apiService.fetchPictureOfTheDay();
      return Artwork.fromJson(data);
    } on ApiException catch (e) {
      print("ArtworkRepository PoTD Error: $e");
      return Artwork( // Fallback Artwork
        id: 'fallback_potd_api_error',
        artworkTitle: 'Picture of the Day (Network Error)',
        imageUrl: 'https://images.pexels.com/photos/1269968/pexels-photo-1269968.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        artistName: 'System',
        year: 'N/A',
        category: 'Could not connect: ${e.message}',
      );
    } catch (e) {
      print("ArtworkRepository PoTD Unexpected Error: $e");
      return Artwork( // Fallback Artwork
        id: 'fallback_potd_unexpected_error',
        artworkTitle: 'Picture of the Day (Loading Error)',
        imageUrl: 'https://images.pexels.com/photos/753339/pexels-photo-753339.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        artistName: 'System',
        year: 'N/A',
        category: 'An unexpected error occurred.',
      );
    }
  }
}