// lib/pages/artatlas_gallery_page.dart
import 'dart:async';
import 'dart:math' as math; // For pi
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // kIsWeb, kDebugMode, Uint8List
import 'package:flutter/material.dart';
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/providers/gallery_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/repositories/artwork_repository.dart';
// import 'package:hack_front/repositories/artwork_repository.dart'; // Not directly used
import 'package:hack_front/services/api_service.dart';
import 'package:hack_front/utils/glow_gradinet.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:hack_front/utils/wodden_frame.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';

class ArtatlasGalleryPage extends StatefulWidget {
  const ArtatlasGalleryPage({super.key});

  @override
  State<ArtatlasGalleryPage> createState() => _ArtatlasGalleryPageState();
}

class _ArtatlasGalleryPageState extends State<ArtatlasGalleryPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _drawerScrollController = ScrollController();
  final ScrollController _galleryArtworksScrollController = ScrollController();
  BoxFit _currentBoxFit = BoxFit.cover;

  late AnimationController _glowController;
  bool _isAiGlowActive = false;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecordingAudio = false;
  bool _isProcessingAudio = false;
  String? _recordedAudioPathOrUrl;
  Timer? _recordingTimer;
  int _recordingSecondsLeft = 5;

  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription<PlayerState>? _playerStateChangeSubscription;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _drawerScrollController.addListener(_onDrawerScroll);
    _galleryArtworksScrollController.addListener(_onGalleryArtworksScroll);

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isProcessingAudio = false;
          _isAiGlowActive = false;
          _glowController.stop();
        });
      }
    });

    _playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        if (mounted && _isProcessingAudio) {
          setState(() {
            _isProcessingAudio = false;
            _isAiGlowActive = false;
            _glowController.stop();
          });
        }
      }
    });
    if (kDebugMode) {
      _audioPlayer.onLog.listen((msg) {
        debugPrint('AudioPlayer Log: $msg');
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGalleryContent();
    });
  }

  Future<void> _initializeGalleryContent() async {
    if (!mounted) return;
    final provider = Provider.of<GalleryProvider>(context, listen: false);

    if (provider.galleries.isEmpty && !provider.isLoadingGalleries) {
      if (kDebugMode) {
        debugPrint(
          "[ArtatlasGalleryPage _initializeGalleryContent] Galleries list is empty. Fetching galleries...",
        );
      }
      await provider.fetchGalleries();
      if (!mounted) return;

      if (provider.galleries.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            "[ArtatlasGalleryPage _initializeGalleryContent] Galleries fetched (${provider.galleries.length}). Selecting first gallery: ${provider.galleries.first.name}.",
          );
        }
        provider.selectGalleryAndLoadArtworks(provider.galleries.first);
      } else {
        if (kDebugMode) {
          debugPrint(
            "[ArtatlasGalleryPage _initializeGalleryContent] Galleries fetched, but the list is still empty.",
          );
        }
      }
    } else if (provider.galleries.isNotEmpty &&
        provider.selectedGallery == null) {
      if (kDebugMode) {
        debugPrint(
          "[ArtatlasGalleryPage _initializeGalleryContent] Galleries loaded, but no gallery selected. Selecting first: ${provider.galleries.first.name}.",
        );
      }
      provider.selectGalleryAndLoadArtworks(provider.galleries.first);
    } else if (provider.selectedGallery != null &&
        provider.galleryArtworks.isEmpty &&
        !provider.isLoadingGalleryArtworks) {
      if (kDebugMode) {
        debugPrint(
          "[ArtatlasGalleryPage _initializeGalleryContent] Gallery '${provider.selectedGallery!.name}' is selected, but artworks are empty. Fetching artworks.",
        );
      }
      provider.selectGalleryAndLoadArtworks(provider.selectedGallery!);
    } else {
      if (kDebugMode) {
        debugPrint(
          "[ArtatlasGalleryPage _initializeGalleryContent] Initial content setup seems complete or in progress. Selected Gallery: ${provider.selectedGallery?.name}, Artworks: ${provider.galleryArtworks.length}",
        );
      }
    }
  }

  void _onDrawerScroll() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    if (_drawerScrollController.position.pixels >=
            _drawerScrollController.position.maxScrollExtent - 200 &&
        !provider.isLoadingGalleries &&
        provider.hasMoreGalleries) {
      if (kDebugMode) {
        debugPrint(
          "[ArtatlasGalleryPage _onDrawerScroll] Loading more galleries.",
        );
      }
      provider.fetchGalleries(loadMore: true);
    }
  }

  void _onGalleryArtworksScroll() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    if (_galleryArtworksScrollController.hasClients &&
        _galleryArtworksScrollController.position.pixels >=
            _galleryArtworksScrollController.position.maxScrollExtent - 50 &&
        !provider.isLoadingGalleryArtworks &&
        provider.hasMoreGalleryArtworks) {
      if (kDebugMode) {
        debugPrint(
          "[ArtatlasGalleryPage _onGalleryArtworksScroll] Loading more artworks for gallery: ${provider.selectedGallery?.name}. hasMore: ${provider.hasMoreGalleryArtworks}",
        );
      }
      provider.loadMoreGalleryArtworks();
    }
  }

  @override
  void dispose() {
    _drawerScrollController.removeListener(_onDrawerScroll);
    _drawerScrollController.dispose();
    _galleryArtworksScrollController.removeListener(_onGalleryArtworksScroll);
    _galleryArtworksScrollController.dispose();
    _glowController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  void _toggleImageFit() {
    setState(() {
      _currentBoxFit = _currentBoxFit == BoxFit.cover
          ? BoxFit.contain
          : BoxFit.cover;
    });
  }

  Future<void> _handleAskAiAudio() async {
    final galleryProvider = Provider.of<GalleryProvider>(
      context,
      listen: false,
    );
    if (galleryProvider.selectedArtwork == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an artwork first.")),
        );
      }
      return;
    }
    if (_isProcessingAudio && !_isRecordingAudio) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("AI is currently responding.")),
        );
      }
      return;
    }

    if (_isRecordingAudio) {
      await _stopRecordingAndSend(isTimerExpired: false);
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      try {
        String? recordingPath;
        if (!kIsWeb) {
          final directory = await getApplicationDocumentsDirectory();
          recordingPath =
              '${directory.path}/artatlas_query_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: recordingPath ?? '',
        );
        _recordedAudioPathOrUrl = recordingPath;

        if (mounted) {
          setState(() {
            _isRecordingAudio = true;
            _isAiGlowActive = true;
            _glowController.repeat();
            _recordingSecondsLeft = 5;
          });

          _recordingTimer?.cancel();
          _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (!mounted) {
              timer.cancel();
              return;
            }
            if (_recordingSecondsLeft > 1) {
              if (mounted) {
                setState(() {
                  _recordingSecondsLeft--;
                });
              }
            } else {
              timer.cancel();
              if (_isRecordingAudio && mounted) {
                if (kDebugMode) {
                  debugPrint(
                    "Recording timer expired. Stopping automatically.",
                  );
                }
                _stopRecordingAndSend(isTimerExpired: true);
              }
            }
          });
        }
      } catch (e) {
        _recordingTimer?.cancel();
        if (kDebugMode) {
          debugPrint("Error starting recording: $e");
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error starting recording: ${e.toString()}"),
            ),
          );
          setState(() {
            _isRecordingAudio = false;
            _isAiGlowActive = false;
            _glowController.stop();
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission denied.")),
        );
      }
    }
  }

  Future<void> _stopRecordingAndSend({required bool isTimerExpired}) async {
    _recordingTimer?.cancel();

    if (!_isRecordingAudio && !isTimerExpired) {
      if (kDebugMode) {
        debugPrint(
          "_stopRecordingAndSend called but not recording and not by timer. Exiting.",
        );
      }
      return;
    }
    if (isTimerExpired == false &&
        _isRecordingAudio == false &&
        _isProcessingAudio == true) {
      if (kDebugMode) {
        debugPrint(
          "_stopRecordingAndSend called by button, but timer might have already stopped it and started processing. Exiting.",
        );
      }
      return;
    }

    final scaffoldMessenger = mounted ? ScaffoldMessenger.of(context) : null;
    final apiServiceProvider = mounted
        ? Provider.of<ApiService>(context, listen: false)
        : null;

    if (apiServiceProvider == null) {
      if (kDebugMode) {
        debugPrint(
          "ApiService provider not available or widget not mounted in _stopRecordingAndSend.",
        );
      }
      if (mounted) {
        setState(() {
          _isRecordingAudio = false;
          _isAiGlowActive = false;
          _glowController.stop();
          _isProcessingAudio = false;
        });
      }
      return;
    }

    try {
      final String? pathOrUrl = await _audioRecorder.stop();
      if (!mounted) {
        return;
      }

      if (_isRecordingAudio || isTimerExpired) {
        setState(() {
          _isRecordingAudio = false;
          _isProcessingAudio = true;
        });
      }

      if (pathOrUrl != null) {
        _recordedAudioPathOrUrl = pathOrUrl;
        if (kDebugMode) {
          debugPrint(
            "Recording stopped. Output: $_recordedAudioPathOrUrl. Timer expired: $isTimerExpired",
          );
        }

        Uint8List audioResponseBytes;
        if (kIsWeb) {
          final response = await http.get(Uri.parse(_recordedAudioPathOrUrl!));
          if (!mounted) {
            return;
          }
          if (response.statusCode == 200) {
            audioResponseBytes = await apiServiceProvider.askAiWithAudioBytes(
              response.bodyBytes,
              'web_audio.m4a',
            );
          } else {
            throw Exception(
              'Failed to fetch audio from blob URL: ${response.statusCode}',
            );
          }
        } else {
          audioResponseBytes = await apiServiceProvider.askAiWithAudioFile(
            _recordedAudioPathOrUrl!,
          );
        }

        if (!mounted) {
          return;
        }
        try {
          await _audioPlayer.play(BytesSource(audioResponseBytes));
        } catch (e) {
          if (kDebugMode) {
            debugPrint("Error playing AI response: $e");
          }
          scaffoldMessenger?.showSnackBar(
            SnackBar(content: Text("Error playing AI audio: ${e.toString()}")),
          );
          if (mounted) {
            setState(() {
              _isProcessingAudio = false;
              _isAiGlowActive = false;
              _glowController.stop();
            });
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint("Recording stop returned null path/URL.");
        }
        scaffoldMessenger?.showSnackBar(
          const SnackBar(content: Text("Failed to finalize recording.")),
        );
        if (mounted) {
          setState(() {
            _isProcessingAudio = false;
            _isAiGlowActive = false;
            _glowController.stop();
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error in stopRecordingAndSend: $e");
      }
      scaffoldMessenger?.showSnackBar(
        SnackBar(content: Text("Error processing audio: ${e.toString()}")),
      );
      if (mounted) {
        setState(() {
          _isRecordingAudio = false;
          _isProcessingAudio = false;
          _isAiGlowActive = false;
          _glowController.stop();
        });
      }
    }
  }

  Widget _buildMainArtworkDisplay(
    BuildContext context,
    GalleryProvider provider,
  ) {
    const Color placeholderTextColor = Colors.white70;
    Widget displayContent;
    bool shouldWrapInArtworkBox = false;

    if (provider.galleries.isEmpty && provider.isLoadingGalleries) {
      displayContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(placeholderTextColor),
            ),
            SizedBox(height: 10),
            Text(
              "Loading galleries...",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    } else if (provider.selectedGallery == null) {
      displayContent = GestureDetector(
        onTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        child: Center(
          child: Text(
            'Tap to select or loading gallery...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    } else if (provider.isLoadingGalleryArtworks &&
        provider.galleryArtworks.isEmpty) {
      displayContent = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(placeholderTextColor),
            ),
            SizedBox(height: 10),
            Text(
              "Loading artworks...",
              style: TextStyle(color: placeholderTextColor),
            ),
          ],
        ),
      );
    } else if (provider.selectedArtwork != null) {
      if (provider.selectedArtwork!.imageUrl != null &&
          provider.selectedArtwork!.imageUrl!.isNotEmpty &&
          !provider.selectedArtwork!.imageUrl!.contains("placeholder.com")) {
        shouldWrapInArtworkBox = true;
        displayContent = GestureDetector(
          onTap: _toggleImageFit,
          child: CachedNetworkImage(
            imageUrl: provider.selectedArtwork!.imageUrl!,
            fit: _currentBoxFit,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(placeholderTextColor),
              ),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 60,
                    color: placeholderTextColor,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Image not available",
                    style: TextStyle(color: placeholderTextColor),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        shouldWrapInArtworkBox = true;
        displayContent = const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 60,
                color: placeholderTextColor,
              ),
              SizedBox(height: 8),
              Text(
                "No image for this artwork",
                style: TextStyle(color: placeholderTextColor),
              ),
            ],
          ),
        );
      }
    } else if (provider.galleryArtworksErrorMessage != null) {
      displayContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Error loading artworks: ${provider.galleryArtworksErrorMessage}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    } else if (!provider.isLoadingGalleryArtworks &&
        provider.galleryArtworks.isEmpty &&
        provider.selectedGallery != null) {
      displayContent = const Center(
        child: Text(
          'No artworks in this gallery.',
          textAlign: TextAlign.center,
          style: TextStyle(color: placeholderTextColor, fontSize: 16),
        ),
      );
    } else {
      displayContent = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(placeholderTextColor),
            ),
            SizedBox(height: 10),
            Text(
              'Preparing content...',
              style: TextStyle(color: placeholderTextColor),
            ),
          ],
        ),
      );
    }

    if (shouldWrapInArtworkBox) {
      return WoodenFrameBox(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // Ensure the container itself can be constrained if needed, or relies on parent constraints
          constraints: BoxConstraints(
            // Example: Constrain max height if image is very tall
            maxHeight:
                MediaQuery.of(context).size.height * 0.5, // Adjust as needed
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                offset: Offset(5, 5),
              ),
            ],
            // color: Colors.black,
            // borderRadius: BorderRadius.circular(18),
          ),
          // clipBehavior: Clip.antiAlias,
          //  padding: const EdgeInsets.all(8),
          child: displayContent,
        ),
      );
    } else {
      // When not showing the box, let the content be centered within the available space.
      // The parent Center widget in the main build method will handle centering this.
      return displayContent;
    }
  }

  // ... (Rest of the file: _buildGalleryArtworksList, build, and _buildSimpleNavLink are the same)

  Widget _buildGalleryArtworksList(
    BuildContext context,
    GalleryProvider provider,
  ) {
    const Color itemPlaceholderColor = Colors.white60;

    if (provider.selectedGallery == null) {
      return const SizedBox.shrink();
    }

    List<Artwork> artworksToList = provider.galleryArtworks.where((artwork) {
      return provider.selectedArtwork == null ||
          artwork.artistUrl != provider.selectedArtwork!.artistUrl;
    }).toList();

    bool showListContainer =
        artworksToList.isNotEmpty ||
        provider.hasMoreGalleryArtworks ||
        (provider.isLoadingGalleryArtworks && artworksToList.isEmpty);

    if (provider.galleryArtworks.length == 1 &&
        provider.selectedArtwork != null &&
        provider.galleryArtworks.first.id == provider.selectedArtwork!.id) {
      showListContainer = false;
    }

    if (!showListContainer) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        height: 110,
        width:
            MediaQuery.of(context).size.width *
            (ResponsiveUtil.isMobile(context) ? 0.8 : 0.5),
        margin: const EdgeInsets.only(top: 15),
        child: ListView.builder(
          controller: _galleryArtworksScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount:
              artworksToList.length +
              ((provider.isLoadingGalleryArtworks &&
                          artworksToList.isEmpty &&
                          provider.hasMoreGalleryArtworks) ||
                      (provider.hasMoreGalleryArtworks &&
                          artworksToList.isNotEmpty)
                  ? 1
                  : 0),
          itemBuilder: (_, index) {
            if (provider.isLoadingGalleryArtworks &&
                artworksToList.isEmpty &&
                index == 0 &&
                provider.hasMoreGalleryArtworks) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation(itemPlaceholderColor),
                    ),
                  ),
                ),
              );
            }

            if (index < artworksToList.length) {
              final artwork = artworksToList[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentBoxFit = BoxFit.cover;
                  });
                  provider.setSelectedArtwork(artwork);
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      (artwork.imageUrl != null &&
                          artwork.imageUrl!.isNotEmpty &&
                          !artwork.imageUrl!.contains("placeholder.com"))
                      ? CachedNetworkImage(
                          imageUrl: artwork.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => Container(
                            color: Colors.black12,
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation(
                                    itemPlaceholderColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (c, u, e) => Container(
                            color: Colors.black12,
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 30,
                              color: itemPlaceholderColor.withOpacity(0.7),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.black12,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 30,
                            color: itemPlaceholderColor.withOpacity(0.7),
                          ),
                        ),
                ),
              );
            } else if (provider.hasMoreGalleryArtworks &&
                index == artworksToList.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: provider.isLoadingGalleryArtworks
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation(
                              itemPlaceholderColor,
                            ),
                          ),
                        )
                      : const SizedBox(width: 24, height: 24),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtil.isMobile(context);

    final galleryProvider = Provider.of<GalleryProvider>(context);
    final ThemeData currentTheme = Theme.of(context);

    final String backgroundImagePath =
        Theme.of(context).brightness == Brightness.dark
        ? "https://sdmntprwestus3.oaiusercontent.com/files/00000000-c7a0-61fd-a482-c8d70d7cc0f5/raw?se=2025-06-15T10%3A10%3A42Z&sp=r&sv=2024-08-04&sr=b&scid=80bb6183-2941-550f-bc46-608def8cdb3d&skoid=864daabb-d06a-46b3-a747-d35075313a83&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2025-06-14T21%3A36%3A37Z&ske=2025-06-15T21%3A36%3A37Z&sks=b&skv=2024-08-04&sig=Cgupgt23J3qeQBlUyGCgJr67wgKtVqOirDUlo5g5fgo%3D"
        : "https://sdmntprwestus3.oaiusercontent.com/files/00000000-1340-61fd-b6b6-1eb997ec0352/raw?se=2025-06-15T10%3A06%3A57Z&sp=r&sv=2024-08-04&sr=b&scid=a46102e3-8f7d-5ef4-b110-8fc4f6d7b12d&skoid=864daabb-d06a-46b3-a747-d35075313a83&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2025-06-15T07%3A08%3A39Z&ske=2025-06-16T07%3A08%3A39Z&sks=b&skv=2024-08-04&sig=mLs4uURY3bt6fm/VGOOCMpyJ2c3H7aH5LfJW7Fbiy7A%3D";
    final Color navLinkColor = Colors.white.withOpacity(0.8);

    Widget pageScaffold = Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (innerContext) => IconButton(
            icon: Icon(
              isMobile ? CupertinoIcons.bars : CupertinoIcons.app_badge,
              color: Colors.white,
            ),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: "Open galleries",
          ),
        ),
        centerTitle: false,
        title: Text(
          galleryProvider.selectedGallery?.name ?? 'Gallery',
          style:
              currentTheme.appBarTheme.titleTextStyle ??
              TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        ),
        actions: isMobile
            ? []
            : [
                _buildSimpleNavLink("Home", 0, context, navLinkColor),
                _buildSimpleNavLink("Collection", 2, context, navLinkColor),
                const SizedBox(width: 20),
              ],
      ),
      drawer: Drawer(
        backgroundColor: currentTheme.colorScheme.surface.withOpacity(0.95),
        child: Consumer<GalleryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingGalleries && provider.galleries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.galleriesErrorMessage != null &&
                provider.galleries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Error fetching galleries: ${provider.galleriesErrorMessage}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: currentTheme.colorScheme.error),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => provider.fetchGalleries(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (provider.galleries.isEmpty && !provider.isLoadingGalleries) {
              return Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: currentTheme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            CupertinoIcons.back,
                            color: currentTheme.colorScheme.onSurfaceVariant,
                          ),
                          tooltip: "Close drawer",
                        ),
                        Text(
                          'Galleries',
                          style: currentTheme.textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w300,
                                color:
                                    currentTheme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "No galleries found. Please try again later.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: currentTheme.hintColor),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: _drawerScrollController,
              itemCount:
                  provider.galleries.length +
                  (provider.hasMoreGalleries ? 1 : 0) +
                  1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: currentTheme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            CupertinoIcons.back,
                            color: currentTheme.colorScheme.onSurfaceVariant,
                          ),
                          tooltip: "Close drawer",
                        ),
                        Text(
                          'Galleries',
                          style: currentTheme.textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w300,
                                color:
                                    currentTheme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  );
                }
                final galleryItemIndex = index - 1;
                if (galleryItemIndex < provider.galleries.length) {
                  final gallery = provider.galleries[galleryItemIndex];
                  bool isSelected = provider.selectedGalleryId == gallery.id;
                  return ListTile(
                    leading:
                        (gallery.imageUrl != null &&
                            gallery.imageUrl!.isNotEmpty &&
                            !gallery.imageUrl!.contains("placeholder.com"))
                        ? CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              gallery.imageUrl!,
                            ),
                            backgroundColor: currentTheme
                                .colorScheme
                                .surfaceContainerHighest,
                          )
                        : CircleAvatar(
                            backgroundColor:
                                currentTheme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.collections_bookmark_outlined,
                              color:
                                  currentTheme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                    title: Text(
                      gallery.name ?? gallery.title ?? 'Unnamed Gallery',
                      style: TextStyle(
                        color: currentTheme.textTheme.bodyLarge?.color,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'Curator: ${gallery.curator ?? "N/A"}\nArt: ${gallery.itemsCountGalleriesPage ?? "N/A"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: currentTheme.hintColor,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: currentTheme.colorScheme.primaryContainer
                        .withOpacity(0.3),
                    isThreeLine: true,
                    onTap: () {
                      if (kDebugMode) {
                        debugPrint(
                          "[Drawer onTap] Selecting gallery: ${gallery.name}",
                        );
                      }
                      setState(() {
                        _currentBoxFit = BoxFit.cover;
                        if (_isAiGlowActive ||
                            _isRecordingAudio ||
                            _isProcessingAudio) {
                          _audioRecorder.stop();
                          _audioPlayer.stop();
                          _recordingTimer?.cancel();
                          _isRecordingAudio = false;
                          _isProcessingAudio = false;
                          _isAiGlowActive = false;
                          _glowController.stop();
                        }
                      });
                      provider.selectGalleryAndLoadArtworks(gallery);
                      Navigator.pop(context);
                    },
                  );
                } else if (provider.hasMoreGalleries) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: currentTheme.colorScheme.primary,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: galleryProvider.selectedArtwork != null ? 3 : 1,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isMobile ? screenWidth * 0.05 : screenWidth * 0.28,
                      right: isMobile ? screenWidth * 0.05 : screenWidth * 0.28,
                      top: isMobile
                          ? kToolbarHeight * 0.5
                          : kToolbarHeight * 0.3,
                      bottom: isMobile
                          ? kToolbarHeight * 0.2
                          : kToolbarHeight * 0.1,
                    ),
                    child: _buildMainArtworkDisplay(context, galleryProvider),
                  ),
                ),
              ),
              _buildGalleryArtworksList(context, galleryProvider),
              SizedBox(height: isMobile ? 70 : 80),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: Colors.black.withOpacity(0.75),
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isProcessingAudio && !_isRecordingAudio)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            else
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _handleAskAiAudio,
                icon: Icon(
                  _isRecordingAudio
                      ? CupertinoIcons.stop_fill
                      : CupertinoIcons.wand_stars,
                  color: Colors.white,
                  size: 18,
                ),
                label: _isRecordingAudio
                    ? Text(
                        '$_recordingSecondsLeft s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      )
                    : const Text(
                        'Ask AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  if (galleryProvider.selectedArtwork != null) {
                    if (galleryProvider
                        .selectedArtwork!
                        .detailsInImage!
                        .isEmpty) {
                      final artworkRepository = Provider.of<ArtworkRepository>(
                        context,
                        listen: false,
                      );
                      final artwork = await artworkRepository
                          .getPictureOfTheDay(
                            galleryProvider.selectedArtwork!.mongoId,
                          );
                      Provider.of<GalleryProvider>(
                        context,
                        listen: false,
                      ).setSelectedArtwork(artwork);
                    }

                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        final artwork = galleryProvider.selectedArtwork!;
                        return AlertDialog(
                          backgroundColor: Colors.black.withOpacity(0.9),
                          title: Text(
                            artwork.artworkTitle ?? "Artwork Details",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text(
                                  'Artist: ${artwork.artistName ?? "N/A"}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                if (artwork.year != null)
                                  Text(
                                    'Year: ${artwork.year}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                if (artwork.description != null &&
                                    artwork.description!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    artwork.description!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                                if (artwork.interpretation != null &&
                                    artwork.interpretation!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    artwork.interpretation!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text(
                                'Close',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No artwork selected to show info."),
                        ),
                      );
                    }
                  }
                },
                label: const Text(
                  'Info',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                icon: const Icon(
                  CupertinoIcons.info_circle_fill,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (_isAiGlowActive) {
      return Stack(
        fit: StackFit.expand,
        children: [
          pageScaffold,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) {
                  final angle = _glowController.value * 2 * math.pi;
                  final gradient = SweepGradient(
                    startAngle: 0.0,
                    endAngle: 2 * math.pi,
                    transform: GradientRotation(angle),
                    colors: const [
                      CupertinoColors.systemCyan,
                      CupertinoColors.activeBlue,
                      CupertinoColors.systemPurple,
                      CupertinoColors.systemBlue,
                      CupertinoColors.systemCyan,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  );
                  return CustomPaint(
                    painter: GradientBorderPainter(
                      gradient: gradient,
                      strokeWidth: 4,
                      blurSigma: 8,
                      borderRadius: 0,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return pageScaffold;
    }
  }

  Widget _buildSimpleNavLink(
    String text,
    int targetIndex,
    BuildContext buildContext,
    Color color,
  ) {
    final navigationProvider = Provider.of<NavigationProvider>(
      buildContext,
      listen: false,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: InkWell(
        onTap: () => navigationProvider.onItemTapped(targetIndex),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
