import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/podcast.dart';
import 'providers/podcast_provider.dart';
import 'screens/podcast_list_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PodcastAdapter());
  await Hive.openBox('podcasts');

  runApp(
    ChangeNotifierProvider(
      create: (context) => PodcastProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podcast App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PodcastListScreen(),
    );
  }
}
