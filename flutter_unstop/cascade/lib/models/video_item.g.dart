// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoItemAdapter extends TypeAdapter<VideoItem> {
  @override
  final int typeId = 0;

  @override
  VideoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoItem(
      id: fields[0] as String,
      filePath: fields[1] as String,
      title: fields[2] as String,
      likes: fields[3] as int,
      views: fields[4] as int,
      createdAt: fields[5] as DateTime,
      isLiked: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VideoItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.likes)
      ..writeByte(4)
      ..write(obj.views)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isLiked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}