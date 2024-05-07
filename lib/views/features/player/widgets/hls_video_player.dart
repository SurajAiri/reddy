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
  late SettingsController settingsController;
  @override
  void initState() {
    super.initState();
    settingsController = Get.find<SettingsController>();
    var lockPostId = settingsController.focusPostId.value;
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
      // video player lock and release
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        settingsController.lockVideoPlayer(widget.postId);
        controller.setControlsVisibility(false);
      } else if (event.betterPlayerEventType == BetterPlayerEventType.pause &&
          settingsController.focusPostId.value == widget.postId) {
        settingsController.releaseVideoPlayer(widget.postId);
      } else if (event.betterPlayerEventType ==
              BetterPlayerEventType.finished &&
          settingsController.focusPostId.value == widget.postId) {
        settingsController.releaseVideoPlayer(widget.postId);
      }

      // video sound change
      if (event.betterPlayerEventType == BetterPlayerEventType.setVolume) {
        if (event.parameters?['volume'] == 0) {
          widget.onMuteChange?.call(true);
        } else {
          widget.onMuteChange?.call(false);
        }
      }
      // playback speed change
      if (event.betterPlayerEventType == BetterPlayerEventType.setSpeed) {
        widget.onPlaybackSpeedChange?.call(event.parameters?['speed']);
      }
    });
    if (widget.mute) {
      controller.setVolume(0);
    }

    settingsController.focusPostId.listenAndPump((value) {
      if (!mounted) return;
      if (value != null &&
          value != "" &&
          value != widget.postId &&
          controller.isPlaying() == true) {
        controller.pause();
      } else if (value == widget.postId &&
          controller.isPlaying() == false &&
          settingsController.autoPlay.value) {
        controller.play();
        controller.setControlsVisibility(false);
      }
    });
    controller.setSpeed(widget.playbackSpeed);
  }

  @override
  void dispose() {
    settingsController.releaseVideoPlayer(widget.postId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.postId),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1 &&
            settingsController.focusPostId.value == null) {
          settingsController.lockVideoPlayer(widget.postId);
        } else if (visibilityInfo.visibleFraction < 1 &&
            settingsController.focusPostId.value == widget.postId) {
          settingsController.releaseVideoPlayer(widget.postId);
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
