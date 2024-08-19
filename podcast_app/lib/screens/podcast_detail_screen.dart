import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/podcast.dart';
import '../providers/podcast_provider.dart';

class PodcastDetailScreen extends StatefulWidget {
  final Podcast podcast;

  const PodcastDetailScreen({super.key, required this.podcast});

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<bool> _isPlayingSubscription;

  @override
  void initState() {
    super.initState();
    final podcastProvider = Provider.of<PodcastProvider>(context, listen: false);
    _positionSubscription = podcastProvider.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
    _durationSubscription = podcastProvider.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      }
    });
    _isPlayingSubscription = podcastProvider.isPlayingStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _isPlayingSubscription.cancel();
    super.dispose();
  }

  void _togglePlayPause() async {
    final podcastProvider = Provider.of<PodcastProvider>(context, listen: false);
    try {
      if (podcastProvider.isPlaying) {
        await podcastProvider.pausePodcast();
      } else {
        await podcastProvider.playPodcast(widget.podcast);
      }
    } catch (e) {
      print('Oynatma/duraklatma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final podcastProvider = Provider.of<PodcastProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.podcast.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(widget.podcast.cover,
                  width: 200, height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(
              widget.podcast.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('By ${widget.podcast.creator}',
                style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text(widget.podcast.description),
            const SizedBox(height: 16),
            Slider(
              value: _currentPosition.inSeconds.toDouble(),
              max: _totalDuration.inSeconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _currentPosition = Duration(seconds: value.toInt());
                });
              },
              onChangeEnd: (value) {
                podcastProvider.seek(Duration(seconds: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_currentPosition)),
                  Text(_formatDuration(_totalDuration)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _togglePlayPause,
                icon: Icon(podcastProvider.isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(podcastProvider.isPlaying ? 'Duraklat' : 'Oynat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}