import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cascade/models/video_item.dart';
import 'package:cascade/providers/video_provider.dart';

class VideoControls extends StatelessWidget {
  final VideoItem video;

  const VideoControls({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Like button
          Consumer<VideoProvider>(
            builder: (context, provider, child) {
              return GestureDetector(
                onTap: () {
                  provider.likeCurrentVideo();
                  
                  // Show feedback animation
                  _showLikeAnimation(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          video.isLiked ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(video.isLiked),
                          color: video.isLiked ? Colors.red : Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${video.likes}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Views count
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '${video.views}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Share button (placeholder)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.share,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  void _showLikeAnimation(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        right: 50,
        bottom: 150,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -50 * value),
              child: Opacity(
                opacity: 1.0 - value,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            );
          },
          onEnd: () {
            overlayEntry.remove();
          },
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}