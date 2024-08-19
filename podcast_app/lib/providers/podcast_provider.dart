import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/podcast.dart';

class PodcastProvider with ChangeNotifier {
  Box podcastBox = Hive.box('podcasts');
  List<Podcast> _podcasts = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Podcast? _currentPodcast;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _positionController = StreamController<Duration>.broadcast();

  final _isPlayingController = StreamController<bool>.broadcast();
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  void _updateIsPlaying(bool value) {
    _isPlaying = value;
    _isPlayingController.add(value);
    notifyListeners();
  }

  List<Podcast> get podcasts => _podcasts;
  bool get isPlaying => _isPlaying;
  Podcast? get currentPodcast => _currentPodcast;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  PodcastProvider() {
    _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
    });
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
    fetchPodcasts();
    _initializeNotifications();
  }

  Future<void> fetchPodcasts() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/podcasts/'));
      if (response.statusCode == 200) {
        final List<dynamic> podcastJson = json.decode(response.body);
        if (podcastJson.isEmpty) {
          throw StateError('Podcast listesi boş.');
        }
        _podcasts = podcastJson.map((json) => Podcast.fromJson(json)).toList();
        for (var podcast in _podcasts) {
          podcastBox.put(podcast.id, podcast.toJson());
        }
        notifyListeners();
      } else {
        throw Exception('Podcastler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Podcast verilerini alırken hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(Podcast podcast) async {
    podcast.isFavorite = !podcast.isFavorite;
    podcastBox.put(podcast.id, podcast.toJson());
    notifyListeners();
    try {
      await http.put(Uri.parse('http://10.0.2.2:3000/podcasts/${podcast.id}/favorite'));
    } catch (e) {
      print('Favori durumu güncellenirken hata oluştu: $e');
      // Hata durumunda favori durumunu geri al
      podcast.isFavorite = !podcast.isFavorite;
      podcastBox.put(podcast.id, podcast.toJson());
      notifyListeners();
    }
  }

  Future<void> playPodcast(Podcast podcast) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }
      _currentPodcast = podcast;
      _isPlaying = true;
      await _audioPlayer.setUrl(podcast.url);
      
      // Kaydedilmiş pozisyonu yükle ve hemen yayınla
      final prefs = await SharedPreferences.getInstance();
      final savedPosition = prefs.getInt('${podcast.id}_position') ?? 0;
      final duration = Duration(seconds: savedPosition);
      _positionController.add(duration);
      
      await _audioPlayer.seek(duration);
      await _audioPlayer.play();
      
      // Normal pozisyon akışını başlat
      _audioPlayer.positionStream.listen((position) {
        _positionController.add(position);
      });
    } catch (e) {
      print('Podcast oynatma hatası: $e');
      _isPlaying = false;
      _currentPodcast = null;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> pausePodcast() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
      final position = await _audioPlayer.position;
      await handlePosition('save', position: position);
      await flutterLocalNotificationsPlugin.cancelAll();
      notifyListeners();
    }
  }

  Future<void> handlePosition(String action, {Duration? position}) async {
    if (_currentPodcast != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_currentPodcast!.id}_position';
      
      if (action == 'save') {
        final currentPosition = position ?? await _audioPlayer.position;
        await prefs.setInt(key, currentPosition.inSeconds);
      } else if (action == 'load') {
        final savedPosition = prefs.getInt(key);
        if (savedPosition != null) {
          await _audioPlayer.seek(Duration(seconds: savedPosition));
        }
      }
    }
  }

  Future<void> resumePodcast() async {
    if (!_isPlaying && _currentPodcast != null) {
      await handlePosition('load');
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> seek(Duration position) async {
    if (_audioPlayer != null) {
      await _audioPlayer.seek(position);
      notifyListeners();
    }
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _positionController.close();
    super.dispose();
  }
}