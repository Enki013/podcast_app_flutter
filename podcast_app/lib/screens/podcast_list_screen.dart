import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/podcast_provider.dart';

import 'podcast_detail_screen.dart';

class PodcastListScreen extends StatelessWidget {
  const PodcastListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final podcastProvider = Provider.of<PodcastProvider>(context);
    print('Number of podcasts: ${podcastProvider.podcasts.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcasts'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: podcastProvider.podcasts.length,
              itemBuilder: (context, index) {
                final podcast = podcastProvider.podcasts[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: Image.network(podcast.cover,
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(podcast.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(podcast.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text('By ${podcast.creator}',
                            style:
                                const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        podcast.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: podcast.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () => podcastProvider.toggleFavorite(podcast),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PodcastDetailScreen(podcast: podcast),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (podcastProvider.isPlaying &&
              podcastProvider.currentPodcast != null)
            Container(
              color: Colors.grey[200],
              child: ListTile(
                leading: Image.network(podcastProvider.currentPodcast!.cover,
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(podcastProvider.currentPodcast!.title),
                subtitle: Text('By ${podcastProvider.currentPodcast!.creator}'),
                trailing: IconButton(
                  icon: Icon(
                    podcastProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    if (podcastProvider.isPlaying) {
                      podcastProvider.pausePodcast();
                    } else {
                      podcastProvider.resumePodcast();
                    }
                  },
                ),
                onTap: () {
          //player screen
                },
              ),
            ),
        ],
      ),
    );
  }
}