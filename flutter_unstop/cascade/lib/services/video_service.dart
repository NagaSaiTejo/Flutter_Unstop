import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cascade/models/video_item.dart';
import 'package:cascade/services/hive_service.dart';

class VideoService {
  static const List<String> _sampleVideoUrls = [
    'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  ];

  // Initialize service with sample videos if no videos exist
  static Future<void> init() async {
    final existingVideos = HiveService.getAllVideos();
    
    if (existingVideos.isEmpty) {
      await _createSampleVideos();
    }
  }

  // Create sample videos for demo purposes
  static Future<void> _createSampleVideos() async {
    final sampleTitles = [
      'Beautiful Sunset',
      'Mountain Adventure',
      'City Lights',
      'Ocean Waves',
      'Forest Walk'
    ];

    for (int i = 0; i < _sampleVideoUrls.length; i++) {
      final video = VideoItem(
        id: 'sample_${i}_${DateTime.now().millisecondsSinceEpoch}',
        filePath: _sampleVideoUrls[i],
        title: sampleTitles[i],
        likes: Random().nextInt(100),
        views: Random().nextInt(1000),
        createdAt: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
        isLiked: Random().nextBool(),
      );
      
      await HiveService.saveVideo(video);
    }
  }

  // Get all videos in random order
  static List<VideoItem> getAllVideosShuffled() {
    final videos = HiveService.getAllVideos();
    videos.shuffle(Random());
    return videos;
  }

  // Add new video from file picker
  static Future<VideoItem?> addVideoFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        // Copy file to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final videosDir = Directory('${appDir.path}/videos');
        if (!await videosDir.exists()) {
          await videosDir.create(recursive: true);
        }
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newPath = '${videosDir.path}/${timestamp}_$fileName';
        await file.copy(newPath);

        // Create video item
        final video = VideoItem(
          id: 'user_${timestamp}',
          filePath: newPath,
          title: fileName.split('.').first,
          createdAt: DateTime.now(),
        );

        await HiveService.saveVideo(video);
        return video;
      }
    } catch (e) {
      print('Error adding video: $e');
    }
    return null;
  }

  // Delete video
  static Future<void> deleteVideo(String videoId) async {
    final video = HiveService.getVideo(videoId);
    if (video != null) {
      // Delete local file if it exists
      if (!video.filePath.startsWith('http')) {
        final file = File(video.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Remove from database
      await HiveService.deleteVideo(videoId);
    }
  }

  // Get video by ID
  static VideoItem? getVideo(String videoId) {
    return HiveService.getVideo(videoId);
  }

  // Update video stats
  static Future<void> likeVideo(String videoId) async {
    await HiveService.toggleLike(videoId);
  }

  static Future<void> incrementViews(String videoId) async {
    await HiveService.incrementViews(videoId);
  }
}