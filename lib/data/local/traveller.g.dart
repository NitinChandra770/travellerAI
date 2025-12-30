// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traveller.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TravellerAdapter extends TypeAdapter<Traveller> {
  @override
  final int typeId = 0;

  @override
  Traveller read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Traveller()
      ..name = fields[0] as String
      ..age = fields[1] as String?
      ..email = fields[2] as String?
      ..mobile = fields[3] as String
      ..travelType = fields[4] as String?
      ..interests = (fields[5] as List?)?.cast<String>()
      ..isPreferenceSet = fields[6] == null ? false : fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, Traveller obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.mobile)
      ..writeByte(4)
      ..write(obj.travelType)
      ..writeByte(5)
      ..write(obj.interests)
      ..writeByte(6)
      ..write(obj.isPreferenceSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravellerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
