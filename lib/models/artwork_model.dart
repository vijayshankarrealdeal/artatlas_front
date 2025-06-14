// lib/models/artwork_model.dart

import 'package:hack_front/services/api_service.dart';

class HistoricalContext {
  final String? artistHistory;
  final String? paintingHistory;
  final String? historicalSignificance;

  HistoricalContext({
    this.artistHistory,
    this.paintingHistory,
    this.historicalSignificance,
  });

  factory HistoricalContext.fromJson(Map<String, dynamic> json) {
    return HistoricalContext(
      artistHistory: json['artist_history'] as String?,
      paintingHistory: json['painting_history'] as String?,
      historicalSignificance: json['historical_significance'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artist_history': artistHistory,
      'painting_history': paintingHistory,
      'historical_significance': historicalSignificance,
    }..removeWhere((key, value) => value == null);
  }
}

// Class for objects within the "tour_guide_explanation" list
class TourGuideSection {
  final String? section;
  final String? text;

  TourGuideSection({this.section, this.text});

  factory TourGuideSection.fromJson(Map<String, dynamic> json) {
    return TourGuideSection(
      section: json['section'] as String?,
      text: json['text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'section': section, 'text': text}
      ..removeWhere((key, value) => value == null);
  }
}

// Main Artwork class
class Artwork {
  final String id; // Corresponds to "artworks_id"
  final String? mongoId; // Corresponds to "_id"
  final String? artworkTitle;
  final String? artistName;
  final String? year;
  final String? medium;
  final String? dimensions;
  final String? currentLocation;
  final String? artworkUrl;
  final String? imageUrl;
  final String? detailsInImage;
  final String? description;
  final String? interpretation;
  final String? mood;
  final List<String>? keywords;
  final HistoricalContext? historicalContext;
  final String? artistBiography;
  final List<TourGuideSection>? tourGuideExplanation;
  final String? style;
  final String? category;
  final String? artistUrl;

  Artwork({
    required this.id,
    this.mongoId,
    this.artworkTitle,
    this.artistName,
    this.year,
    this.medium,
    this.dimensions,
    this.currentLocation,
    this.artworkUrl,
    this.imageUrl,
    this.detailsInImage,
    this.description,
    this.interpretation,
    this.mood,
    this.keywords,
    this.historicalContext,
    this.artistBiography,
    this.tourGuideExplanation,
    this.style,
    this.category,
    this.artistUrl,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    // Helper to parse list of strings
    List<String>? parseStringList(dynamic listData) {
      if (listData is List) {
        return listData.map((item) => item.toString()).toList();
      }
      return null;
    }

    // Helper to parse list of TourGuideSection
    List<TourGuideSection>? parseTourGuideList(dynamic listData) {
      if (listData is List) {
        return listData
            .map(
              (item) => TourGuideSection.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return null;
    }

    // Determine if artworks_id exists, if not, use _id, if not that either, generate one
    String determinedId =
        json['artworks_id'] as String? ??
        json['_id']
            as String? ?? // Use _id from artwork if artworks_id is missing
        'missing_id_${DateTime.now().millisecondsSinceEpoch}';

    return Artwork(
      id: determinedId,
      mongoId: json['_id'] as String?,
      artworkTitle: json['artwork_title'] as String? ?? 'Untitled Artwork',
      artistName: json['artist_name'] as String? ?? 'Unknown Artist',
      year: json['year'] as String?,
      medium: json['medium'] as String?,
      dimensions: json['dimensions'] as String?,
      currentLocation: json['current_location'] as String?,
      artworkUrl: json['artwork_url'] as String?,
      imageUrl:
          json['image_url'] != null && (json['image_url'] as String).isNotEmpty
          ? "${ApiService.baseUrl}/image/proxy-image?url=${Uri.encodeComponent(json['image_url'] as String)}"
          : 'https://via.placeholder.com/1260x750.png?text=No+Image+Available',
      detailsInImage: json['details_in_image'] as String?,
      description: json['description'] as String?,
      interpretation: json['interpretation'] as String?,
      mood: json['mood'] as String?,
      keywords: parseStringList(json['keywords']),
      historicalContext: json['historical_context'] != null
          ? HistoricalContext.fromJson(
              json['historical_context'] as Map<String, dynamic>,
            )
          : null,
      artistBiography: json['artist_biography'] as String?,
      tourGuideExplanation: parseTourGuideList(json['tour_guide_explanation']),
      style: json['style'] as String?,
      category: json['category'] as String?,
      artistUrl: json['artist_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artworks_id': id,
      '_id': mongoId,
      'artwork_title': artworkTitle,
      'artist_name': artistName,
      'year': year,
      'medium': medium,
      'dimensions': dimensions,
      'current_location': currentLocation,
      'artwork_url': artworkUrl,
      // For toJson, we might want to store the original image_url if we are sending it back to an API
      // that doesn't expect the proxied version. This depends on your backend.
      // For simplicity, I'll keep it as is, but be mindful of this.
      'image_url': imageUrl,
      'details_in_image': detailsInImage,
      'description': description,
      'interpretation': interpretation,
      'mood': mood,
      'keywords': keywords,
      'historical_context': historicalContext?.toJson(),
      'artist_biography': artistBiography,
      'tour_guide_explanation': tourGuideExplanation
          ?.map((e) => e.toJson())
          .toList(),
      'style': style,
      'category': category,
      'artist_url': artistUrl,
    }..removeWhere(
      (key, value) => value == null || (value is List && value.isEmpty),
    );
  }
}
