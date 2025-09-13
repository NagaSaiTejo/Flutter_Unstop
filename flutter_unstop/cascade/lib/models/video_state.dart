enum VideoPlayerState {
  loading,
  ready,
  playing,
  paused,
  error,
}

class VideoState {
  final String videoId;
  final VideoPlayerState playerState;
  final Duration position;
  final Duration duration;
  final bool isBuffering;

  const VideoState({
    required this.videoId,
    required this.playerState,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isBuffering = false,
  });

  VideoState copyWith({
    String? videoId,
    VideoPlayerState? playerState,
    Duration? position,
    Duration? duration,
    bool? isBuffering,
  }) {
    return VideoState(
      videoId: videoId ?? this.videoId,
      playerState: playerState ?? this.playerState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}