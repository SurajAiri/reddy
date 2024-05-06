// hls video player
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HlsVideoPlayer extends StatefulWidget {
  const HlsVideoPlayer({
    super.key,
    required this.video,
    this.autoPlay = true,
    this.mute = true,
    required this.thumbnailUrl,
    this.onMuteChange,
    this.onPlaybackSpeedChange,
    this.playbackSpeed = 1.0,
    required this.postId,
  });
  final RedditVideo video;
  final String thumbnailUrl;
  final bool autoPlay;
  final bool mute;
  final double playbackSpeed;
  final Function(bool isMute)? onMuteChange;
  final Function(double speed)? onPlaybackSpeedChange;
  final String postId;

  @override
  State<HlsVideoPlayer> createState() => _HlsVideoPlayerState();
}

class _HlsVideoPlayerState extends State<HlsVideoPlayer> {
  late BetterPlayerController controller;
  @override
  void initState() {
    super.initState();
    var postId = Get.find<SettingsController>().focusPostId.value;
    // bool autoPlay = (postId == null || postId == "") && widget.autoPlay;
    controller = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: widget.video.aspectRatio,
        // autoPlay: autoPlay,
        autoPlay: false,
        showPlaceholderUntilPlay: false,
        placeholder: Image.network(
          widget.thumbnailUrl,
          height: widget.video.height.toDouble(),
          width: widget.video.width.toDouble(),
          fit: BoxFit.cover,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.video.hlsUrl,
      ),
    );

    controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        Get.find<SettingsController>().focusPostId.value = widget.postId;
      } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
        Get.find<SettingsController>().focusPostId.value = null;
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.setVolume) {
        if (event.parameters?['volume'] == 0) {
          widget.onMuteChange?.call(true);
        } else {
          widget.onMuteChange?.call(false);
        }
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.setSpeed) {
        widget.onPlaybackSpeedChange?.call(event.parameters?['speed']);
      }
    });
    if (widget.mute) {
      controller.setVolume(0);
    }

    Get.find<SettingsController>().focusPostId.listen((value) {
      if (value != null && value != "" && value != widget.postId) {
        controller.pause();
      } else if (value == widget.postId && controller.isPlaying() == false) {
        controller.play();
        controller.setControlsVisibility(false);
      }
    });
    controller.setSpeed(widget.playbackSpeed);
  }

  @override
  void dispose() {
    super.dispose();
    print("we got disposed");
    Get.find<SettingsController>().focusPostId.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.postId),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1) {
          Get.find<SettingsController>().focusPostId.value = widget.postId;
          // print("visible ${widget.postId}");
        }
      },
      child: AspectRatio(
        aspectRatio: widget.video.aspectRatio,
        child: BetterPlayer(
          controller: controller,
        ),
      ),
    );
  }
}
