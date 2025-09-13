import 'package:hive/hive.dart';

part 'video_item.g.dart';

@HiveType(typeId: 0)
class VideoItem extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String filePath;
  
  @HiveField(2)
  String title;
  
  @HiveField(3)
  int likes;
  
  @HiveField(4)
  int views;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  bool isLiked;

  VideoItem({
    required this.id,
    required this.filePath,
    required this.title,
    this.likes = 0,
    this.views = 0,
    required this.createdAt,
    this.isLiked = false,
  });

  VideoItem copyWith({
    String? id,
    String? filePath,
    String? title,
    int? likes,
    int? views,
    DateTime? createdAt,
    bool? isLiked,
  }) {
    return VideoItem(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}