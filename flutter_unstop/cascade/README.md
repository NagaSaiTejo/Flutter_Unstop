# Cascade - Reels-style Gallery App

A Flutter application that provides a TikTok/Instagram Reels-like short video experience with seamless auto-play, offline capabilities, and persistent user interactions.

## Features

### Core Functionality
- **Vertical Video Feed**: Full-screen PageView with one video per screen
- **Auto-play Logic**: Automatically plays the visible video, pauses others
- **Preloading**: Preloads next video for seamless playback (no buffering/loading delays)
- **Like & Save Actions**: Instant UI updates with offline queuing
- **Add Videos**: Users can add new videos from their device gallery
- **Random Shuffle**: Video order reshuffles when new videos are added

### Technical Features
- **State Management**: Provider pattern for clean separation of concerns
- **Offline Storage**: Hive database for persistent likes, views, and video metadata
- **Memory Management**: Proper video controller disposal to prevent memory leaks
- **Viewport Detection**: Only the most visible video plays at any time
- **Performance Optimized**: Controllers for distant videos are disposed to save memory

## Architecture

### State Management
- **VideoProvider**: Manages video list, current index, and user interactions
- **VideoPlayerProvider**: Handles video controllers and playback states

### Services Layer
- **HiveService**: Database operations for video metadata persistence
- **VideoService**: Video file management and CRUD operations

### UI Components
- **HomePage**: Main feed with vertical PageView
- **VideoPlayerWidget**: Individual video player with auto-play logic
- **VideoControls**: Like/share buttons with animations
- **VideoInfoOverlay**: Video title and metadata display

## How to Run

### Prerequisites
- Flutter SDK (3.6.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android/iOS device or simulator

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone [your-repo-url]
   cd cascade
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-specific Setup

#### Android
- Minimum SDK version: 21
- Required permissions are automatically handled by the packages

#### iOS
- iOS 12.0 or higher
- Required permissions are automatically handled by the packages

## Mock Server Setup

This app uses local storage and doesn't require a mock server. Sample videos are loaded from:
- Public video URLs for demonstration
- User-added videos from device gallery

Sample video sources include:
- Sample Videos (sample-videos.com)
- Google Cloud Storage public videos
- User's local video files

## Architecture Notes

### Video Playback Strategy
1. **Initialization**: Videos are initialized as they come into view
2. **Preloading**: Next video is preloaded for seamless transitions
3. **Disposal**: Controllers for videos >3 positions away are disposed
4. **Memory Management**: Automatic cleanup prevents memory leaks

### Data Flow
1. **User Action** (scroll, like) → **Provider** → **Service Layer** → **Database**
2. **UI Updates**: Optimistic updates for instant feedback
3. **Persistence**: Hive database ensures data survives app restarts

### Performance Optimizations
- **Lazy Loading**: Videos are initialized only when needed
- **Resource Cleanup**: Automatic disposal of unused video controllers
- **Efficient Pagination**: Random shuffle without expensive re-sorting
- **Preload Strategy**: Smart preloading balances performance and memory usage

### Offline Capabilities
- **Local Database**: Hive stores all video metadata offline
- **File Management**: Local video files are properly managed
- **Instant Updates**: UI updates immediately, sync happens in background

## Dependencies

### Core Dependencies
- **flutter**: UI framework
- **provider**: State management
- **video_player**: Video playback functionality
- **hive & hive_flutter**: Local database
- **path_provider**: File system access
- **file_picker**: Video file selection

### Development Dependencies
- **flutter_test**: Testing framework
- **flutter_lints**: Code quality

## Project Structure

```
lib/
├── main.dart                 # App entry point with initialization
├── theme.dart               # App theming (dark video app theme)
├── models/
│   ├── video_item.dart      # Video data model with Hive annotations
│   ├── video_item.g.dart    # Generated Hive adapter
│   └── video_state.dart     # Video playback state model
├── services/
│   ├── hive_service.dart    # Database operations
│   └── video_service.dart   # Video file management
├── providers/
│   ├── video_provider.dart         # Video list state management
│   └── video_player_provider.dart  # Video playback state management
├── screens/
│   └── home_page.dart       # Main video feed screen
└── widgets/
    ├── video_player_widget.dart    # Individual video player
    ├── video_controls.dart         # Like/share controls
    └── video_info_overlay.dart     # Video metadata display
```

## Testing

Run tests with:
```bash
flutter test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.