// hls video player
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:meme_life_v2/models/reddit/reddit_post_model.dart';

class HlsVideoPlayer extends StatefulWidget {
  const HlsVideoPlayer({
    super.key,
    required this.video,
  });
  final RedditVideo video;

  @override
  State<HlsVideoPlayer> createState() => _HlsVideoPlayerState();
}

class _HlsVideoPlayerState extends State<HlsVideoPlayer> {
  late BetterPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.video.aspectRatio,
      child: BetterPlayer.network(
        widget.video.hlsUrl,
        betterPlayerConfiguration: BetterPlayerConfiguration(
          aspectRatio: widget.video.aspectRatio,
          autoPlay: true,
          showPlaceholderUntilPlay: false,
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
