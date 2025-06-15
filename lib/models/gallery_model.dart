// lib/models/gallery_model.dart

import 'package:hack_front/services/api_service.dart';

class GalleryModel {
  final String id; // Corresponds to "_id"
  final String? name;
  final String? collectionUrl;
  final String? curator;
  final String? title;
  final String? imageUrl;
  final String? itemsCountGalleriesPage;
  final String? artworksId; // Corresponds to "artworks_id"

  GalleryModel({
    required this.id,
    this.name,
    this.collectionUrl,
    this.curator,
    this.title,
    this.imageUrl,
    this.itemsCountGalleriesPage,
    this.artworksId,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['_id'] as String,
      name: json['name'] as String?,
      collectionUrl: json['collection_url'] as String?,
      curator: json['curator'] as String?,
      title: json['title'] as String?,
      imageUrl:
          "${ApiService.baseUrl}/image/proxy-image?url=${json['image_url']}"
              as String?,
      itemsCountGalleriesPage: json['items_count_galleries_page'] as String?,
      artworksId: json['artworks_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'collection_url': collectionUrl,
      'curator': curator,
      'title': title,
      'image_url': imageUrl,
      'items_count_galleries_page': itemsCountGalleriesPage,
      'artworks_id': artworksId,
    }..removeWhere((key, value) => value == null);
  }
}
