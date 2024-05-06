// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';
import 'package:reddy/views/features/player/widgets/hls_video_player.dart';
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
              // Get.toNamed(AllRoutes.postDetailsScreen, arguments: post);
              // Get.to(SinglePostScreen(post: post));
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
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      NetworkImage(post.user?.iconImg ?? kDemoImgUrl),
                ),
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
                          Text(
                            "r/${post.subreddit}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
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
            // Text(
            //   "content: ${post.id}",
            //   // "nsfw ${post.isNSFW} | over18 ${post.over18} | spoiler ${post.spoiler} | quran: ${post.quarantine}",
            //   style: TextStyle(
            //     fontSize: 12,
            //     color: Colors.grey,
            //   ),
            // ),

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
            // const SizedBox(height:` 4),
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
                // const SizedBox(width: 8),
                // _PostButton(
                //   icon: Icons.comment,
                //   text: post.numComments.toString(),
                // ),
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

  RedditImage _getImagePostUrl() {
    if (imageQuality == ImageQuality.highest) return post.previews.last;

    int ind = min(
        ImageQuality.values.indexOf(imageQuality), post.previews.length - 1);
    return post.previews[ind];
  }

  Widget buildImagePart(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    RedditImage img = _getImagePostUrl();
    // double height = width * post.thumbnail.height / post.thumbnail.width;
// height using aspect ratio
    double height = width * img.height / img.width;
    print("width: $width,  height: $height, url: ${img.url}");
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: post.isNSFW && safeContentOnly
          ? _buildImgNotShow(width)
          : Image.network(
              img.url,
              width: width,
              height: height,
              fit: BoxFit.fill,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return SizedBox(
                  width: width,
                  height: height,
                  child: Center(
                    child: LinearProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildImgNotShow(width),
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
    print("video player");
    return GetBuilder<SettingsController>(
      builder: (controller) => HlsVideoPlayer(
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

class _PostButton extends StatelessWidget {
  const _PostButton({
    super.key,
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
