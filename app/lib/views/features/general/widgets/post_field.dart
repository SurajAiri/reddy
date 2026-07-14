// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';
import 'package:reddy/models/reddit/reddit_user_model.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';
import 'package:reddy/views/features/player/widgets/hls_video_player.dart';
import 'package:reddy/views/features/posts/screens/post_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostField extends StatelessWidget {
  const PostField({
    super.key,
    required this.post,
    this.safeContentOnly = true,
    this.isSinglePost = false,
    this.imageQuality = ImageQuality.medium,
    this.postUrlPressed,
  });
  final RedditPostModel post;
  final bool safeContentOnly;
  final bool isSinglePost;
  final ImageQuality imageQuality;

  /// called when there is no media to show but PostContentType is not text
  final Function()? postUrlPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSinglePost
          ? null
          : () {
              Get.to(SinglePostScreen(post: post));
            },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AuthorAvatar(post: post),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "r/${post.subreddit}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  post.isGallery
                                      ? "GALLERY"
                                      : post.contentType.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Text(
                            timeago.format(post.created.toLocal()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 4),
            Text(
              post.title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            if (post.isNSFW && safeContentOnly)
              _buildImgNotShow(MediaQuery.of(context).size.width)
            else if (post.isGallery && post.galleryImages.isNotEmpty)
              buildGalleryPart(context)
            else if (post.video == null &&
                post.previews.isEmpty &&
                post.contentType != PostContentType.text)
              TextButton(
                onPressed: postUrlPressed,
                child: Text(post.url),
              )
            else if ((post.contentType == PostContentType.video ||
                    post.contentType == PostContentType.gifv) &&
                post.video != null)
              buildVideoPlayer()
            else if (post.previews.isNotEmpty)
              buildImagePart(context)
            else if (post.contentType == PostContentType.text)
              Text(
                post.selftext,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PostButton(
                  icon: Icons.thumb_up,
                  text: post.ups.toString(),
                ),
                const SizedBox(width: 8),
                _PostButton(
                  icon: Icons.thumb_down,
                  text: post.downs.toString(),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    UiUtility.showToast("Yet to add share post");
                  },
                  child: _PostButton(
                    icon: Icons.share,
                    text: "Share",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  RedditImage _getImagePostUrl(List<RedditImage> images) {
    if (imageQuality == ImageQuality.highest) return images.last;

    int ind =
        min(ImageQuality.values.indexOf(imageQuality), images.length - 1);
    return images[ind];
  }

  Widget buildImagePart(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    RedditImage img = _getImagePostUrl(post.previews);
    double height = width * img.height / img.width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: post.isNSFW && safeContentOnly
          ? _buildImgNotShow(width)
          : _NetworkImage(url: img.url, width: width, height: height),
    );
  }

  /// Renders Reddit gallery posts (multiple images) as a swipeable
  /// carousel with a page counter, instead of the old behaviour of
  /// showing nothing but a raw `reddit.com/gallery/<id>` link.
  Widget buildGalleryPart(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final images = post.galleryImages;
    final cover = images.first;
    double height = width * cover.height / max(cover.width, 1);
    height = height.clamp(150, width * 1.5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: _GalleryCarousel(
        images: images,
        width: width,
        height: height,
      ),
    );
  }

  Container _buildImgNotShow(double width) {
    return Container(
      color: Colors.red,
      width: double.maxFinite,
      height: width * post.aspectRatio,
      child: Center(
        child: Text(
          post.isNSFW ? "NSFW Content" : "Error loading image",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget buildVideoPlayer() {
    return GetBuilder<SettingsController>(
      builder: (controller) => ModernHlsVideoPlayer(
        postId: post.id,
        video: post.video!,
        thumbnailUrl: post.thumbnail.url,
        autoPlay: controller.autoPlay.value,
        mute: !controller.sound.value,
        playbackSpeed: controller.playbackSpeed.value,
        onMuteChange: (isMute) => controller.sound.value = !isMute,
        onPlaybackSpeedChange: (speed) =>
            controller.playbackSpeed.value = speed,
      ),
    );
  }
}

/// Fetches (and caches) the post author's profile lazily - only once
/// this widget actually gets built (i.e. the post has scrolled into
/// view), instead of the whole feed page firing one request per post
/// up front.
class _AuthorAvatar extends StatefulWidget {
  const _AuthorAvatar({required this.post});
  final RedditPostModel post;

  @override
  State<_AuthorAvatar> createState() => _AuthorAvatarState();
}

class _AuthorAvatarState extends State<_AuthorAvatar> {
  RedditUserModel? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.post.user;
    if (_user == null) {
      RedditApi.fetchUserDetails(username: widget.post.author).then((user) {
        if (!mounted || user == null) return;
        widget.post.user = user;
        setState(() => _user = user);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconUrl = _user?.iconImg;
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[200],
      backgroundImage: iconUrl != null && iconUrl.isNotEmpty
          ? CachedNetworkImageProvider(iconUrl)
          : NetworkImage(kDemoImgUrl) as ImageProvider,
    );
  }
}

/// Thin wrapper so the whole app benefits from disk+memory image
/// caching (previously every image used `Image.network`, which
/// re-downloads on every rebuild/scroll and never caches to disk -
/// a major source of wasted bandwidth and jank while scrolling).
class _NetworkImage extends StatelessWidget {
  const _NetworkImage({
    required this.url,
    required this.width,
    required this.height,
    this.onError,
  });
  final String url;
  final double width;
  final double height;
  final VoidCallback? onError;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.fill,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) => SizedBox(
        width: width,
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) {
        onError?.call();
        return Container(
          color: Colors.red,
          width: width,
          height: height,
          child: const Center(
            child: Text(
              "Error loading image",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
      },
    );
  }
}

class _GalleryCarousel extends StatefulWidget {
  const _GalleryCarousel({
    required this.images,
    required this.width,
    required this.height,
  });
  final List<RedditImage> images;
  final double width;
  final double height;

  @override
  State<_GalleryCarousel> createState() => _GalleryCarouselState();
}

class _GalleryCarouselState extends State<_GalleryCarousel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _NetworkImage(
              url: widget.images[i].url,
              width: widget.width,
              height: widget.height,
            ),
          ),
          if (widget.images.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_index + 1}/${widget.images.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  const _PostButton({
    required this.icon,
    required this.text,
  });
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
