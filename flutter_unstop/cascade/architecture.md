# Cascade - Reels-style Gallery App Architecture

## Overview
A short-video feed app with vertical scrolling, auto-play functionality, offline queuing, and Hive persistence for likes/views data.

## Core Features
1. **Feed UI**: Vertical PageView with one video per screen
2. **Auto-play Logic**: Play visible video, pause others, preload next
3. **State Management**: Provider pattern for video states and user interactions
4. **Offline Storage**: Local video management with add functionality
5. **Persistence**: Hive database for likes/views data

## Architecture Components

### 1. Data Models
- `VideoItem`: Contains video metadata, file path, likes, views
- `VideoState`: Current playback state, loading status

### 2. Services Layer
- `VideoService`: Manages video CRUD operations with local storage
- `HiveService`: Handles persistence of likes/views to Hive database
- `VideoPreloadService`: Manages preloading logic for next videos

### 3. State Management (Provider)
- `VideoProvider`: Central state management for video list, current index
- `VideoPlayerProvider`: Manages video controllers and playback states

### 4. UI Components
- `HomePage`: Main feed with PageView
- `VideoPlayerWidget`: Individual video player with controls
- `VideoControls`: Like button and action overlays
- `AddVideoButton`: Floating action button for adding new videos

### 5. Key Technical Requirements
- Video controllers disposed properly to prevent memory leaks
- Preloading next video for seamless playback
- Random shuffle when new video is added
- Instant UI updates for likes (optimistic updates)
- Viewport detection for auto-play logic

## File Structure
- `lib/models/` - Data models
- `lib/services/` - Business logic and external APIs
- `lib/providers/` - State management
- `lib/screens/` - UI screens
- `lib/widgets/` - Reusable UI components

## Dependencies
- video_player: Video playback functionality
- provider: State management
- hive: Local database for persistence
- path_provider: File system access
- file_picker: Video file selection