import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For a more precise arrow if needed

class ArtatlasGalleryPage extends StatefulWidget {
  const ArtatlasGalleryPage({super.key});

  @override
  State<ArtatlasGalleryPage> createState() => _ArtatlasGalleryPageState();
}

class _ArtatlasGalleryPageState extends State<ArtatlasGalleryPage> {
  double _volume = 0.7;
  bool _isPlaying = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black, // Fallback color
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              // Replace with your actual image URL or use Image.asset
              'assets/images/night.png', // Using the provided image
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(child: Text("Error loading image")),
                );
              },
            ),
          ),
          // Positioned(
          //   top: 50,
          //   left: 20,
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //     decoration: BoxDecoration(
          //       color: Colors.black.withOpacity(0.6),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: const [
          //         Icon(
          //           Icons.location_on_outlined,
          //           color: Colors.white,
          //           size: 18,
          //         ),
          //         SizedBox(width: 8),
          //         Text(
          //           'Chanlibel Museum, Baku Azerbaijan',
          //           style: TextStyle(color: Colors.white, fontSize: 13),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Virtual Tour Title
          Positioned(
            top: 50, // Adjusted to be below the fake window controls
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Galley',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Right Info Panel
          Positioned(
            top: screenHeight * 0.25,
            right: 30,
            width: screenWidth * 0.35, // Adjust width as needed
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'About: Right Main ° Hall 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Museum has huge hall that leads to other sections with masterpieces. Left side of the hall have been attached to it in 1989.',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Major events are took part in this hall, so the walls of it is full with different kind of art woks.', // Typo "woks" kept from image
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Text(
                  //   'Chanlibel Museum 1979',
                  //   style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  // ),
                  // Text(
                  //   'Adim Chanlibel',
                  //   style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  // ),
                  // const SizedBox(height: 20),
                  _buildAudioPlayerControls(),
                ],
              ),
            ),
          ),

          // 4. Hotspot (White circle on the vase)
          // This position is an approximation. In a real app, it might be calculated.
          // Positioned(
          //   left: screenWidth * 0.485, // Approximate horizontal center
          //   top: screenHeight * 0.47, // Approximate vertical center of vase
          //   child: Container(
          //     width: 40,
          //     height: 40,
          //     decoration: BoxDecoration(
          //       color: Colors.white.withOpacity(0.9),
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         color: Colors.black.withOpacity(0.7),
          //         width: 6,
          //       ),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.3),
          //           blurRadius: 5,
          //           spreadRadius: 1,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // 5. Bottom Left: Fullscreen Icon
          // Positioned(
          //   bottom: 20,
          //   left: 20,
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: Colors.black.withOpacity(0.6),
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     child: const Icon(
          //       Icons.fullscreen,
          //       color: Colors.white,
          //       size: 28,
          //     ),
          //   ),
          // ),

          // 6. Bottom Center: Up Arrow
          // Positioned(
          //   bottom: 20,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: Icon(
          //       Icons.keyboard_arrow_up,
          //       color: Colors.white.withOpacity(0.7),
          //       size: 60,
          //       shadows: [
          //         Shadow(
          //           blurRadius: 10.0,
          //           color: Colors.black.withOpacity(0.5),
          //           offset: const Offset(0, 0),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // 7. Bottom Right: Zoom Controls
          // Positioned(
          //   bottom: 20,
          //   right: 20,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.black.withOpacity(0.6),
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         IconButton(
          //           icon: const Icon(Icons.add, color: Colors.white),
          //           onPressed: () {
          //             /* TODO: Implement zoom in */
          //           },
          //           padding: const EdgeInsets.all(4),
          //           constraints: const BoxConstraints(),
          //         ),
          //         Container(
          //           height: 1,
          //           width: 30, // Adjust width to match icon button size
          //           color: Colors.white.withOpacity(0.3),
          //         ),
          //         IconButton(
          //           icon: const Icon(Icons.remove, color: Colors.white),
          //           onPressed: () {
          //             /* TODO: Implement zoom out */
          //           },
          //           padding: const EdgeInsets.all(4),
          //           constraints: const BoxConstraints(),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Widget _buildWindowDot(Color color) {
  //   return Container(
  //     width: 12,
  //     height: 12,
  //     decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  //   );
  // }

  Widget _buildAudioPlayerControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const Text(
              '01:13/10:52',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '1.3x',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 0), // Reduced space
        Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12.0,
                  ),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.grey[700],
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (newVolume) {
                    setState(() {
                      _volume = newVolume;
                    });
                  },
                ),
              ),
            ),
            // This speaker icon from image seems to be a general volume indicator not mute
            // If it's a mute toggle, use something like:
            // IconButton(
            //   icon: Icon(_volume > 0 ? Icons.volume_up : Icons.volume_off, color: Colors.white),
            //   onPressed: () {
            //     setState(() {
            //       if (_volume > 0) _volume = 0;
            //       else _volume = 0.5; // Or previous volume
            //     });
            //   },
            // ),
          ],
        ),
      ],
    );
  }
}
