// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PodcastAdapter extends TypeAdapter<Podcast> {
  @override
  final int typeId = 0;

  @override
  Podcast read(BinaryReader reader) {
    return Podcast(
      id: reader.read()! as int,
      title: reader.read() as String,
      description: reader.read() as String,
      url: reader.read() as String,
      isFavorite: reader.read() as bool,
      cover: reader.read() as String,
      creator: reader.read() as String,
    );
  }

  @override
  void write(BinaryWriter writer, Podcast obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.url);
    writer.write(obj.isFavorite);
    writer.write(obj.cover);
    writer.write(obj.creator);
  }
}