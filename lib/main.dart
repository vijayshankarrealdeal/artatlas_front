import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/artatlas_collections_page.dart';
import 'package:hack_front/artatlas_gallery_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Art Atlas',
      theme: ThemeData(
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: CupertinoColors.darkBackgroundGray,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'FuturaPT', // Or your preferred sans-serif font
      ),
      home: const MuseumHomePage(),
    );
  }
}

class MuseumHomePage extends StatelessWidget {
  const MuseumHomePage({super.key});

  final String imageUrl =
      'https://images.pexels.com/photos/297494/pexels-photo-297494.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2';
  Widget _buildHeader(BuildContext context) {
    // Route createOverlayRoute() {
    //   return PageRouteBuilder(
    //     opaque: false, // Essential for transparency and blur effect
    //     pageBuilder: (context, animation, secondaryAnimation) =>
    //         const MuseumMenuOverlay(),
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       // You can add transitions like FadeTransition if desired
    //       return FadeTransition(opacity: animation, child: child);
    //     },
    //   );
    // }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ART',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                  color: Colors.black,
                ),
              ),
              Text(
                'ATLAS',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _navLink('Top Picks', context),
              _navLink('Galleries', context),
              _navLink('Collection', context),
              const SizedBox(width: 20),
              // IconButton(
              //   icon: const Icon(Icons.menu, color: Colors.black, size: 30),
              //   onPressed: () {
              //     Navigator.of(context).push(createOverlayRoute());
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navLink(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: GestureDetector(
        onTap: () {
          if (text == 'Top Picks') {
            // Navigate to Top Picks page
          } else if (text == 'Galleries') {
            // Navigate to Galleries page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ArtatlasGalleryPage(), // Replace with actual page
              ),
            );
          } else if (text == 'Collection') {
            // Navigate to Collection page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ArtatlasCollectionsPage(), // Replace with actual page
              ),
            );
          }
        },
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // For web or larger screens, constrain the width
    double contentMaxWidth =
        MediaQuery.of(context).size.width * 0.95; // Max width for content

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(CupertinoIcons.search),
      ),
      body: Center(
        // Center the content if screen is wider than contentMaxWidth
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Column(
            children: [
              // _buildWindowBar(),
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 40.0,
                    right: 40.0,
                    bottom: 40.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6, // Give more space to the image
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.width *
                                0.6, // Maintain aspect ratio
                          ), // Ensure image has some height
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text('Image failed to load'),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                      Expanded(
                        flex: 4, // Give less space to the text block
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 20.0,
                          ), // Adjust top padding for text alignment
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                'Picture',
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight
                                      .w300, // Lighter weight for large text
                                  letterSpacing: 1.2,
                                  color: Colors.black,
                                  height: 1.1,
                                ),
                              ),
                              const Text(
                                'OF Day',
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.2,
                                  color: Colors.black,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                '"It is good to love many things, for therein lies the true strength, and whosoever loves much performs much, and can accomplish much, and what is done in love is well done."',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.5,
                                  fontStyle: FontStyle
                                      .normal, // Original is not italic
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Align(
                                alignment: Alignment
                                    .centerLeft, // The original is left aligned
                                child: Text(
                                  '— Vincent Van Gogh',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
