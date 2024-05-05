import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class TestPlayerScreen extends StatefulWidget {
  const TestPlayerScreen({super.key});

  @override
  State<TestPlayerScreen> createState() => _TestPlayerScreenState();
}

class _TestPlayerScreenState extends State<TestPlayerScreen> {
  // https://v.redd.it/2liuwovx6psc1/DASH_720.mp4?source=fallback
  // things i will get <base_url|before dash>, max video quality, hasAudio.

  BetterPlayerDataSource dataSource = BetterPlayerDataSource(
    BetterPlayerDataSourceType.network,
    // "https://v.redd.it/2liuwovx6psc1/HLSPlaylist.m3u8",
    "https://v.redd.it/1edojfo48ysc1/HLSPlaylist.m3u8",
  );
  late BetterPlayerController controller;
  @override
  void initState() {
    super.initState();
    controller = BetterPlayerController(
      BetterPlayerConfiguration(
        controlsConfiguration: BetterPlayerControlsConfiguration(),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Example player"),
      ),
      body: AspectRatio(
        aspectRatio: 16 / 9,
        // child: BetterPlayer.network(
        //   "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        //   betterPlayerConfiguration: const BetterPlayerConfiguration(
        //     aspectRatio: 16 / 9,
        //   ),),
        child: BetterPlayer(
          controller: controller,
        ),
      ),
    );
  }
}
