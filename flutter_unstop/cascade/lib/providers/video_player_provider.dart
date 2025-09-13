import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cascade/models/video_item.dart';
import 'package:cascade/models/video_state.dart';

class VideoPlayerProvider with ChangeNotifier {
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, VideoState> _videoStates = {};
  String? _currentPlayingId;

  Map<String, VideoPlayerController> get controllers => _controllers;
  Map<String, VideoState> get videoStates => _videoStates;
  String? get currentPlayingId => _currentPlayingId;

  // Initialize controller for a video
  Future<void> initializeController(VideoItem video) async {
    if (_controllers.containsKey(video.id)) {
      return; // Already initialized
    }

    try {
      _setVideoState(video.id, VideoPlayerState.loading);

      VideoPlayerController controller;
      if (video.filePath.startsWith('http')) {
        controller = VideoPlayerController.networkUrl(Uri.parse(video.filePath));
      } else {
        controller = VideoPlayerController.file(File(video.filePath));
      }

      _controllers[video.id] = controller;

      // Add listener for state changes
      controller.addListener(() {
        if (_controllers.containsKey(video.id)) {
          _updateVideoState(video.id, controller);
        }
      });

      await controller.initialize();
      controller.setLooping(true);
      
      _setVideoState(video.id, VideoPlayerState.ready);
    } catch (e) {
      print('Error initializing video ${video.id}: $e');
      _setVideoState(video.id, VideoPlayerState.error);
    }
  }

  // Play specific video and pause others
  Future<void> playVideo(String videoId) async {
    // Pause all other videos
    await pauseAllVideos();

    final controller = _controllers[videoId];
    if (controller != null && controller.value.isInitialized) {
      await controller.play();
      _currentPlayingId = videoId;
      _setVideoState(videoId, VideoPlayerState.playing);
    }
  }

  // Pause specific video
  Future<void> pauseVideo(String videoId) async {
    final controller = _controllers[videoId];
    if (controller != null && controller.value.isInitialized) {
      await controller.pause();
      if (_currentPlayingId == videoId) {
        _currentPlayingId = null;
      }
      _setVideoState(videoId, VideoPlayerState.paused);
    }
  }

  // Pause all videos
  Future<void> pauseAllVideos() async {
    for (final entry in _controllers.entries) {
      if (entry.value.value.isInitialized && entry.value.value.isPlaying) {
        await entry.value.pause();
        _setVideoState(entry.key, VideoPlayerState.paused);
      }
    }
    _currentPlayingId = null;
  }

  // Dispose specific controller
  void disposeController(String videoId) {
    final controller = _controllers.remove(videoId);
    if (controller != null) {
      controller.dispose();
    }
    _videoStates.remove(videoId);
    
    if (_currentPlayingId == videoId) {
      _currentPlayingId = null;
    }
  }

  // Get controller for video
  VideoPlayerController? getController(String videoId) {
    return _controllers[videoId];
  }

  // Get video state
  VideoState? getVideoState(String videoId) {
    return _videoStates[videoId];
  }

  // Check if video is playing
  bool isPlaying(String videoId) {
    final controller = _controllers[videoId];
    return controller?.value.isPlaying ?? false;
  }

  // Private helper methods
  void _setVideoState(String videoId, VideoPlayerState state) {
    final currentState = _videoStates[videoId];
    _videoStates[videoId] = VideoState(
      videoId: videoId,
      playerState: state,
      position: currentState?.position ?? Duration.zero,
      duration: currentState?.duration ?? Duration.zero,
      isBuffering: currentState?.isBuffering ?? false,
    );
    notifyListeners();
  }

  void _updateVideoState(String videoId, VideoPlayerController controller) {
    if (!controller.value.isInitialized) return;

    final currentState = _videoStates[videoId];
    _videoStates[videoId] = VideoState(
      videoId: videoId,
      playerState: currentState?.playerState ?? VideoPlayerState.ready,
      position: controller.value.position,
      duration: controller.value.duration,
      isBuffering: controller.value.isBuffering,
    );
    notifyListeners();
  }

  // Preload next video
  Future<void> preloadVideo(VideoItem video) async {
    if (!_controllers.containsKey(video.id)) {
      await initializeController(video);
    }
  }

  // Cleanup - dispose all controllers
  void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _videoStates.clear();
    _currentPlayingId = null;
  }

  @override
  void dispose() {
    disposeAll();
    super.dispose();
  }
}