import 'package:hive/hive.dart';

part 'podcast.g.dart';

@HiveType(typeId: 0)
class Podcast extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String url;

  @HiveField(4)
  bool isFavorite;

  @HiveField(5)
  String cover;

  @HiveField(6)
  String creator;

  Podcast(
      {required this.id,
      required this.title,
      required this.description,
      required this.url,
      this.isFavorite = false,
      required this.cover,
      required this.creator});

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      cover: json['cover'] ?? '',
      creator: json['creator'] ?? 'Unknown Creator',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'isFavorite': isFavorite,
      'cover': cover,
      'creator': creator,
    };
  }
}