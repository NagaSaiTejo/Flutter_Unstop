import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cascade/models/video_item.dart';

class HiveService {
  static const String videosBoxName = 'videos';
  static Box<VideoItem>? _videosBox;

  // In-memory fallback for web or when Hive init fails
  static bool _inMemoryMode = false;
  static final Map<String, VideoItem> _memoryStore = {};

  static Future<void> init() async {
    try {
      // On web, skip Hive entirely and use in-memory storage to avoid IndexedDB backend issues.
      if (kIsWeb) {
        _inMemoryMode = true;
        // ignore: avoid_print
        print('Hive disabled on web: using in-memory storage.');
        return;
      }
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(VideoItemAdapter());
      }

      // Open boxes
      _videosBox = await Hive.openBox<VideoItem>(videosBoxName);
      _inMemoryMode = false;
    } catch (e) {
      // Fallback: use in-memory store on web or when Hive is unavailable
      _inMemoryMode = true;
      // Print a concise note for debugging
      // ignore: avoid_print
      print('Hive init failed (${e.runtimeType}): falling back to in-memory storage.');
    }
  }

  static bool get isInMemory => _inMemoryMode;

  static Box<VideoItem> get videosBox {
    if (_videosBox == null) {
      throw Exception('Hive not initialized. Call HiveService.init() first.');
    }
    return _videosBox!;
  }

  // Video operations
  static Future<void> saveVideo(VideoItem video) async {
    if (_inMemoryMode) {
      _memoryStore[video.id] = video;
    } else {
      await videosBox.put(video.id, video);
    }
  }

  static Future<void> deleteVideo(String videoId) async {
    if (_inMemoryMode) {
      _memoryStore.remove(videoId);
    } else {
      await videosBox.delete(videoId);
    }
  }

  static VideoItem? getVideo(String videoId) {
    if (_inMemoryMode) {
      return _memoryStore[videoId];
    }
    return videosBox.get(videoId);
  }

  static List<VideoItem> getAllVideos() {
    if (_inMemoryMode) {
      return _memoryStore.values.toList();
    }
    return videosBox.values.toList();
  }

  // Update video stats
  static Future<void> updateVideoStats(String videoId, {int? likes, int? views, bool? isLiked}) async {
    if (_inMemoryMode) {
      final video = _memoryStore[videoId];
      if (video != null) {
        _memoryStore[videoId] = video.copyWith(
          likes: likes ?? video.likes,
          views: views ?? video.views,
          isLiked: isLiked ?? video.isLiked,
        );
      }
      return;
    }

    final video = videosBox.get(videoId);
    if (video != null) {
      final updatedVideo = video.copyWith(
        likes: likes ?? video.likes,
        views: views ?? video.views,
        isLiked: isLiked ?? video.isLiked,
      );
      await videosBox.put(videoId, updatedVideo);
    }
  }

  static Future<void> incrementViews(String videoId) async {
    if (_inMemoryMode) {
      final video = _memoryStore[videoId];
      if (video != null) {
        _memoryStore[videoId] = video.copyWith(views: video.views + 1);
      }
      return;
    }

    final video = videosBox.get(videoId);
    if (video != null) {
      final updatedVideo = video.copyWith(views: video.views + 1);
      await videosBox.put(videoId, updatedVideo);
    }
  }

  static Future<void> toggleLike(String videoId) async {
    if (_inMemoryMode) {
      final video = _memoryStore[videoId];
      if (video != null) {
        final newLikedState = !video.isLiked;
        final newLikesCount = newLikedState ? video.likes + 1 : video.likes - 1;
        _memoryStore[videoId] = video.copyWith(
          isLiked: newLikedState,
          likes: newLikesCount,
        );
      }
      return;
    }

    final video = videosBox.get(videoId);
    if (video != null) {
      final newLikedState = !video.isLiked;
      final newLikesCount = newLikedState ? video.likes + 1 : video.likes - 1;

      final updatedVideo = video.copyWith(
        isLiked: newLikedState,
        likes: newLikesCount,
      );
      await videosBox.put(videoId, updatedVideo);
    }
  }

  static Future<void> close() async {
    if (_inMemoryMode) return;
    await _videosBox?.close();
  }
}