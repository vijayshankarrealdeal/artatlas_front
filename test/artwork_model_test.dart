// test/models/artwork_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/services/api_service.dart'; // For ApiService.baseUrl

void main() {
  group('Artwork Model', () {
    test('fromJson should parse basic artwork data correctly', () {
      final jsonMap = {
        "artwork_title": "Mona Lisa",
        "artist_name": "Leonardo da Vinci",
        "year": "1503–1506",
        "category": "Portrait",
        "_id": "mongo123",
        "artworks_id": "art123",
        "image_url": "http://example.com/mona_lisa.jpg",
      };

      final artwork = Artwork.fromJson(jsonMap);

      expect(artwork.id, 'art123');
      expect(artwork.mongoId, 'mongo123');
      expect(artwork.artworkTitle, 'Mona Lisa');
      expect(artwork.artistName, 'Leonardo da Vinci');
      expect(artwork.year, '1503–1506');
      expect(artwork.category, 'Portrait');
      expect(
        artwork.imageUrl,
        '${ApiService.baseUrl}/image/proxy-image?url=http%3A%2F%2Fexample.com%2Fmona_lisa.jpg',
      );
    });

    test('fromJson should use _id if artworks_id is missing', () {
      final jsonMap = {
        "artwork_title": "Starry Night",
        "artist_name": "Vincent van Gogh",
        "_id": "mongo_starry",
        // "artworks_id": null, // Intentionally missing
        "image_url": "http://example.com/starry.jpg",
      };
      final artwork = Artwork.fromJson(jsonMap);
      expect(artwork.id, 'mongo_starry');
      expect(
        artwork.imageUrl,
        '${ApiService.baseUrl}/image/proxy-image?url=http%3A%2F%2Fexample.com%2Fstarry.jpg',
      );
    });

    test('fromJson should handle missing optional fields gracefully', () {
      final jsonMap = {
        "artworks_id": "art789",
        // All other fields missing
      };
      final artwork = Artwork.fromJson(jsonMap);
      expect(artwork.id, 'art789');
      expect(artwork.artworkTitle, 'Untitled Artwork'); // Default value
      expect(artwork.artistName, 'Unknown Artist'); // Default value
      expect(artwork.year, isNull);
      expect(
        artwork.imageUrl,
        'https://via.placeholder.com/1260x750.png?text=No+Image+Available',
      );
    });

    test('fromJson should parse historical_context', () {
      final jsonMap = {
        "artworks_id": "art_hist",
        "historical_context": {
          "artist_history": "Some artist history",
          "painting_history": "Some painting history",
        },
      };
      final artwork = Artwork.fromJson(jsonMap);
      expect(artwork.historicalContext, isNotNull);
      expect(artwork.historicalContext?.artistHistory, "Some artist history");
      expect(
        artwork.historicalContext?.paintingHistory,
        "Some painting history",
      );
    });

    test('toJson should produce a map with non-null values', () {
      final artwork = Artwork(
        id: 'art123',
        artworkTitle: 'Test Title',
        artistName: 'Test Artist',
        year: '2023',
        imageUrl: 'proxied_url',
      );
      final json = artwork.toJson();
      expect(json['artworks_id'], 'art123');
      expect(json['artwork_title'], 'Test Title');
      expect(json['artist_name'], 'Test Artist');
      expect(json['year'], '2023');
      expect(json['image_url'], 'proxied_url');
      expect(json.containsKey('mongoId'), isFalse); // mongoId was null
    });
  });
}
