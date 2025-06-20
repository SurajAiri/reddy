// Modern HLS video player with well-maintained packages
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';

class ModernHlsVideoPlayer extends StatefulWidget {
  const ModernHlsVideoPlayer({
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
  State<ModernHlsVideoPlayer> createState() => _ModernHlsVideoPlayerState();
}

class _ModernHlsVideoPlayerState extends State<ModernHlsVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late SettingsController settingsController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    settingsController = Get.find<SettingsController>();
    _isMuted = widget.mute;
    _initializePlayer();
    _setupSettingsListener();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.hlsUrl),
      );

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: widget.video.aspectRatio,
        autoPlay: false,
        looping: false,
        showControls: true,
        showControlsOnInitialize: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        placeholder: _buildPlaceholder(),
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).primaryColor,
          handleColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
      );

      // Set initial volume
      if (_isMuted) {
        await _videoPlayerController.setVolume(0.0);
      }

      // Set initial playback speed
      await _videoPlayerController.setPlaybackSpeed(widget.playbackSpeed);

      // Add listeners
      _videoPlayerController.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  Widget _buildPlaceholder() {
    return CachedNetworkImage(
      imageUrl: widget.thumbnailUrl,
      height: widget.video.height.toDouble(),
      width: widget.video.width.toDouble(),
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
        child: const Icon(
          Icons.error,
          color: Colors.red,
        ),
      ),
    );
  }

  void _videoListener() {
    if (!mounted) return;

    final bool isPlaying = _videoPlayerController.value.isPlaying;
    final double volume = _videoPlayerController.value.volume;
    final double speed = _videoPlayerController.value.playbackSpeed;

    // Handle play/pause state changes
    if (isPlaying != _isPlaying) {
      _isPlaying = isPlaying;
      
      if (isPlaying) {
        settingsController.lockVideoPlayer(widget.postId);
        // _chewieController?.setControlsVisibility(false);
        // _chewieController.showControls= false;
      } else {
        if (settingsController.focusPostId.value == widget.postId) {
          settingsController.releaseVideoPlayer(widget.postId);
        }
      }
    }

    // Handle volume changes
    final bool isMuted = volume == 0.0;
    if (isMuted != _isMuted) {
      _isMuted = isMuted;
      widget.onMuteChange?.call(isMuted);
    }

    // Handle playback speed changes
    if (speed != widget.playbackSpeed) {
      widget.onPlaybackSpeedChange?.call(speed);
    }

    // Handle video completion
    if (_videoPlayerController.value.position >= _videoPlayerController.value.duration) {
      if (settingsController.focusPostId.value == widget.postId) {
        settingsController.releaseVideoPlayer(widget.postId);
      }
    }
  }

  void _setupSettingsListener() {
    settingsController.focusPostId.listen((value) {
      if (!mounted || !_isInitialized) return;

      if (value != null &&
          value.isNotEmpty &&
          value != widget.postId &&
          _videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      } else if (value == widget.postId &&
          !_videoPlayerController.value.isPlaying &&
          settingsController.autoPlay.value) {
        _videoPlayerController.play();
        // _chewieController?.setControlsVisibility(false);
      }
    });
  }

  void _handleVisibilityChange(VisibilityInfo visibilityInfo) {
    if (!mounted || !_isInitialized) return;

    if (visibilityInfo.visibleFraction == 1.0 &&
        settingsController.focusPostId.value == null) {
      settingsController.lockVideoPlayer(widget.postId);
    } else if (visibilityInfo.visibleFraction < 1.0 &&
        settingsController.focusPostId.value == widget.postId) {
      settingsController.releaseVideoPlayer(widget.postId);
    }
  }

  @override
  void dispose() {
    settingsController.releaseVideoPlayer(widget.postId);
    _videoPlayerController.removeListener(_videoListener);
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.postId),
      onVisibilityChanged: _handleVisibilityChange,
      child: AspectRatio(
        aspectRatio: widget.video.aspectRatio,
        child: _isInitialized && _chewieController != null
            ? Chewie(controller: _chewieController!)
            : _buildPlaceholder(),
      ),
    );
  }
}
