// lib/models/artwork_model.dart

class Artwork {
  final String imageUrl;
  final String title;
  final String year;
  final String artist;

  Artwork({
    required this.imageUrl,
    required this.title,
    required this.year,
    required this.artist,
  });
}

// Sample data (can be in the same file or imported)
final List<Artwork> sampleArtworks = [
  Artwork(
    imageUrl:
        'https://images.pexels.com/photos/2832382/pexels-photo-2832382.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&dpr=2',
    title: 'A Sunday on La Grande Jatte',
    year: '1884/86',
    artist: 'Georges Seurat',
  ),
  Artwork(
    // Using a generic Van Gogh style image as "The Bedroom" isn't directly available on Pexels with free license matching the style
    imageUrl:
        'https://images.pexels.com/photos/1269968/pexels-photo-1269968.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&dpr=2',
    title: 'The Starry Night (Inspired)', // Placeholder title
    year: '1889',
    artist: 'Vincent van Gogh (Style)',
  ),
  Artwork(
    imageUrl:
        'https://images.pexels.com/photos/2885578/pexels-photo-2885578.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&dpr=2',
    title: 'American Gothic (Inspired)', // Placeholder title
    year: '1930',
    artist: 'Grant Wood (Style)',
  ),
  Artwork(
    // Using a generic Hopper style image
    imageUrl:
        'https://images.pexels.com/photos/753339/pexels-photo-753339.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&dpr=2',
    title: 'Nighthawks (Inspired)', // Placeholder title
    year: '1942',
    artist: 'Edward Hopper (Style)',
  ),
  Artwork(
    imageUrl:
        'https://images.pexels.com/photos/159862/art-school-of-athens-raphael-italian-painter-fresco-159862.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&dpr=2',
    title: 'The School of Athens',
    year: '1509-1511',
    artist: 'Raphael',
  ),
  Artwork(
    imageUrl:
        'https://images.pexels.com/photos/374710/pexels-photo-374710.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&dpr=2',
    title: 'Mona Lisa (Inspired)',
    year: 'c. 1503-1506',
    artist: 'Leonardo da Vinci (Style)',
  ),
  Artwork(
    imageUrl:
        'https://images.pexels.com/photos/102100/pexels-photo-102100.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&dpr=2',
    title: 'Abstract Forms',
    year: '20th Century',
    artist: 'Unknown Modernist',
  ),
  Artwork(
    imageUrl:
        'https://images.pexels.com/photos/1616403/pexels-photo-1616403.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&dpr=2',
    title: 'Impressionist Landscape',
    year: 'c. 1874',
    artist: 'Claude Monet (Style)',
  ),
];
