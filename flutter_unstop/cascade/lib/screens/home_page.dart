import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cascade/models/video_item.dart';
import 'package:cascade/providers/video_provider.dart';
import 'package:cascade/providers/video_player_provider.dart';
import 'package:cascade/widgets/video_player_widget.dart';
import 'package:cascade/widgets/video_controls.dart';
import 'package:cascade/widgets/video_info_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentVisibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideosAndPreload();
    });
  }

  Future<void> _loadVideosAndPreload() async {
    final videoProvider = context.read<VideoProvider>();
    final playerProvider = context.read<VideoPlayerProvider>();
    
    await videoProvider.loadVideos();
    
    // Preload first few videos
    if (videoProvider.videos.isNotEmpty) {
      // Initialize and preload current video
      await playerProvider.initializeController(videoProvider.videos[0]);
      
      // Preload next video if exists
      if (videoProvider.videos.length > 1) {
        playerProvider.preloadVideo(videoProvider.videos[1]);
      }
    }
  }

  void _onPageChanged(int index) {
    if (_currentVisibleIndex != index) {
      _currentVisibleIndex = index;
      
      final videoProvider = context.read<VideoProvider>();
      final playerProvider = context.read<VideoPlayerProvider>();
      
      // Update current video index
      videoProvider.setCurrentIndex(index);
      
      // Handle preloading
      _handlePreloading(index, videoProvider, playerProvider);
    }
  }

  void _handlePreloading(int currentIndex, VideoProvider videoProvider, VideoPlayerProvider playerProvider) {
    final videos = videoProvider.videos;
    
    // Preload next video
    final nextIndex = currentIndex + 1;
    if (nextIndex < videos.length) {
      playerProvider.preloadVideo(videos[nextIndex]);
    }
    
    // Dispose videos that are too far away to save memory
    final disposeDistance = 3;
    for (int i = 0; i < videos.length; i++) {
      final distance = (i - currentIndex).abs();
      if (distance > disposeDistance) {
        playerProvider.disposeController(videos[i].id);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<VideoProvider>(
        builder: (context, videoProvider, child) {
          if (videoProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (videoProvider.videos.isEmpty) {
            return _buildEmptyState();
          }

          return Stack(
            children: [
              // Main video feed
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: videoProvider.videos.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final video = videoProvider.videos[index];
                  final isCurrentVideo = index == _currentVisibleIndex;
                  
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video player
                      VideoPlayerWidget(
                        video: video,
                        shouldPlay: isCurrentVideo,
                      ),
                      
                      // Video info overlay
                      VideoInfoOverlay(video: video),
                      
                      // Video controls
                      VideoControls(video: video),
                    ],
                  );
                },
              ),
              
              // Add video button
              Positioned(
                bottom: 50,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () async {
                    await videoProvider.addNewVideo();
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              
              // App title (optional)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Cascade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'No videos yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first video to get started',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FloatingActionButton.extended(
            onPressed: () async {
              final videoProvider = context.read<VideoProvider>();
              await videoProvider.addNewVideo();
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Video',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}