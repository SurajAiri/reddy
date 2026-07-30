// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/link_handler.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/config/utils/utility.dart';
import 'package:reddy/controllers/general/home_controller.dart';
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

  /// Switches the home feed to [subreddit] and pops back to the home
  /// route if we're stacked on top of it (e.g. tapped from inside
  /// SinglePostScreen). There's no separate "subreddit screen" in
  /// this app - HomeController's feed IS the subreddit page, it just
  /// gets reconfigured in place.
  void _openSubreddit(String subreddit) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().updateSubreddit(subreddit);
    }
    Get.until((route) =>
        route.settings.name == AllRoutes.homeScreen || route.isFirst);
  }

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
                              InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () => _openSubreddit(post.subreddit),
                                child: Text(
                                  "r/${post.subreddit}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w600,
                                  ),
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
                onPressed: postUrlPressed ?? () => LinkHandler.open(post.url),
                child: Text(post.url),
              )
            else if ((post.contentType == PostContentType.video ||
                    post.contentType == PostContentType.gifv) &&
                post.video != null)
              buildVideoPlayer()
            else if (post.previews.isNotEmpty)
              buildImagePart(context)
            else if (post.contentType == PostContentType.text)
              MarkdownBody(
                data: post.selftext,
                selectable: false,
                softLineBreak: true,
                onTapLink: (text, href, title) {
                  if (href != null) LinkHandler.open(href);
                },
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.35),
                  a: TextStyle(color: Colors.blue[700], decoration: TextDecoration.underline),
                ),
              ),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              children: [
                // Reddit combines up/downvotes into a single net score
                // and shows it as arrow-score-arrow, not two separate
                // counters - `downs` is basically always 0 on modern
                // reddit anyway (they stopped exposing real downvote
                // counts years ago), so treating it as a second
                // meaningful number was misleading.
                _VoteScore(score: post.ups - post.downs),
                Expanded(
                  child: Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: isSinglePost
                          ? null
                          : () => Get.to(SinglePostScreen(post: post)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: _PostButton(
                          icon: Icons.mode_comment_outlined,
                          text: Utility.compactNumber(post.numComments),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    UiUtility.showToast("Yet to add share post");
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: _PostButton(
                      icon: Icons.share_outlined,
                      text: "Share",
                    ),
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
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final pixelSize =
        (40 * dpr).round().clamp(1, 512); // 20px radius = 40px diameter
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[200],
      backgroundImage: iconUrl != null && iconUrl.isNotEmpty
          ? CachedNetworkImageProvider(
              iconUrl,
              maxWidth: pixelSize,
              maxHeight: pixelSize,
            )
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
    // Decoding at full source resolution when the widget only ever
    // displays at `width x height` logical pixels wastes a lot of
    // memory (a 4000x3000 source decoded for a 400px-wide card is
    // ~10x more pixels than will ever be shown) and is a common
    // cause of scroll jank / OOM in long image-heavy feeds.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      memCacheWidth: (width * dpr).round().clamp(1, 4096),
      memCacheHeight: (height * dpr).round().clamp(1, 4096),
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

/// Reddit's actual vote widget: up arrow, net score, down arrow, all
/// in one pill. No vote-casting is wired up here (this app never
/// authenticates a vote action against reddit's API) so both arrows
/// are static/decorative for now - this only fixes the *display*,
/// which is what was asked for. Score colour hints at sign without
/// needing to track the viewer's own vote state, which isn't
/// available.
class _VoteScore extends StatelessWidget {
  const _VoteScore({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score > 0
        ? Colors.deepOrange
        : score < 0
            ? Colors.blue
            : Colors.grey[700];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_upward_rounded, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            Utility.compactNumber(score),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.grey[500]),
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
