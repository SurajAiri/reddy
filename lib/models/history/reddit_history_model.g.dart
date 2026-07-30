// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reddit_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RedditHistoryModelAdapter extends TypeAdapter<RedditHistoryModel> {
  @override
  final int typeId = 1;

  @override
  RedditHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RedditHistoryModel(
      value: fields[0] as String,
      searchCount: fields[1] as int,
      safe: fields[3] as bool,
    )..lastSearchDate = fields[2] as int;
  }

  @override
  void write(BinaryWriter writer, RedditHistoryModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.searchCount)
      ..writeByte(2)
      ..write(obj.lastSearchDate)
      ..writeByte(3)
      ..write(obj.safe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RedditHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
