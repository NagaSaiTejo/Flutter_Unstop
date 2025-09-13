import 'package:flutter/material.dart';
import 'package:cascade/models/video_item.dart';
import 'package:cascade/services/video_service.dart';

class VideoProvider with ChangeNotifier {
  List<VideoItem> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  List<VideoItem> get videos => _videos;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  VideoItem? get currentVideo => _videos.isNotEmpty ? _videos[_currentIndex] : null;

  Future<void> loadVideos() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _videos = VideoService.getAllVideosShuffled();
      _currentIndex = 0;
    } catch (e) {
      print('Error loading videos: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _videos.length) {
      _currentIndex = index;
      notifyListeners();
      
      // Increment views for the new current video
      final video = _videos[index];
      VideoService.incrementViews(video.id);
    }
  }

  Future<void> likeCurrentVideo() async {
    if (currentVideo != null) {
      await VideoService.likeVideo(currentVideo!.id);
      
      // Update local video object
      final updatedVideo = VideoService.getVideo(currentVideo!.id);
      if (updatedVideo != null) {
        _videos[_currentIndex] = updatedVideo;
        notifyListeners();
      }
    }
  }

  Future<void> addNewVideo() async {
    final newVideo = await VideoService.addVideoFromFile();
    if (newVideo != null) {
      // Reshuffle the entire list when a new video is added
      await loadVideos();
    }
  }

  Future<void> deleteVideo(String videoId) async {
    await VideoService.deleteVideo(videoId);
    _videos.removeWhere((video) => video.id == videoId);
    
    // Adjust current index if necessary
    if (_currentIndex >= _videos.length && _videos.isNotEmpty) {
      _currentIndex = _videos.length - 1;
    } else if (_videos.isEmpty) {
      _currentIndex = 0;
    }
    
    notifyListeners();
  }

  // Get next and previous videos for preloading
  VideoItem? get nextVideo {
    final nextIndex = _currentIndex + 1;
    return nextIndex < _videos.length ? _videos[nextIndex] : null;
  }

  VideoItem? get previousVideo {
    final prevIndex = _currentIndex - 1;
    return prevIndex >= 0 ? _videos[prevIndex] : null;
  }
}