// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 1;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      httpId: fields[13] as String,
      aid: fields[0] as String,
      name: fields[1] as String,
      groupId: fields[12] as int,
      avatar: fields[2] as String,
      authors: (fields[3] as List)?.cast<String>(),
      description: fields[4] as String,
      chapterCount: fields[5] as int,
      favorite: fields[6] as bool,
      needUpdate: fields[7] as bool,
      quick: fields[10] as int,
    )
      ..hasUpdate = fields[8] as bool
      ..updatedAt = fields[9] as DateTime
      .._history = (fields[11] as Map)?.cast<String, dynamic>();
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.aid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatar)
      ..writeByte(3)
      ..write(obj.authors)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.chapterCount)
      ..writeByte(6)
      ..write(obj.favorite)
      ..writeByte(7)
      ..write(obj.needUpdate)
      ..writeByte(8)
      ..write(obj.hasUpdate)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.quick)
      ..writeByte(11)
      ..write(obj._history)
      ..writeByte(12)
      ..write(obj.groupId)
      ..writeByte(13)
      ..write(obj.httpId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
