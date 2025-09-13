import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:cascade/models/video_item.dart';
import 'package:cascade/models/video_state.dart';
import 'package:cascade/providers/video_player_provider.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoItem video;
  final bool shouldPlay;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.shouldPlay,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndPlay();
    });
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldPlay != widget.shouldPlay) {
      _handlePlaybackChange();
    }
  }

  void _initializeAndPlay() async {
    final provider = context.read<VideoPlayerProvider>();
    
    // Initialize controller if not already done
    await provider.initializeController(widget.video);
    
    // Play or pause based on shouldPlay
    if (widget.shouldPlay) {
      await provider.playVideo(widget.video.id);
    } else {
      await provider.pauseVideo(widget.video.id);
    }
  }

  void _handlePlaybackChange() async {
    final provider = context.read<VideoPlayerProvider>();
    
    if (widget.shouldPlay) {
      await provider.playVideo(widget.video.id);
    } else {
      await provider.pauseVideo(widget.video.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayerProvider>(
      builder: (context, provider, child) {
        final controller = provider.getController(widget.video.id);
        final videoState = provider.getVideoState(widget.video.id);

        if (controller == null || !controller.value.isInitialized) {
          return _buildLoadingWidget();
        }

        if (videoState?.playerState == VideoPlayerState.error) {
          return _buildErrorWidget();
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            
            // Loading indicator when buffering
            if (videoState?.isBuffering == true)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            
            // Play/Pause overlay on tap
            GestureDetector(
              onTap: () {
                if (provider.isPlaying(widget.video.id)) {
                  provider.pauseVideo(widget.video.id);
                } else {
                  provider.playVideo(widget.video.id);
                }
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: provider.isPlaying(widget.video.id) ? 0.0 : 0.7,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        provider.isPlaying(widget.video.id) 
                            ? Icons.pause 
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading video',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}