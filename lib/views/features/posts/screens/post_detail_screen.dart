import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/utility.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/controllers/post/post_detail_controller.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';
import 'package:reddy/views/features/general/widgets/post_field.dart';
import 'package:reddy/views/features/posts/widgets/comment_tile.dart';
import 'package:reddy/views/widgets/red_lottie_anim.dart';
import 'package:reddy/config/utils/asset_paths.dart';
import 'package:reddy/views/widgets/screen_layout.dart';

class SinglePostScreen extends StatefulWidget {
  const SinglePostScreen({super.key, required this.post});
  final RedditPostModel post;

  @override
  State<SinglePostScreen> createState() => _SinglePostScreenState();
}

class _SinglePostScreenState extends State<SinglePostScreen> {
  // Tagged by post id so opening several single-post screens on top of
  // each other (post -> linked post -> ...) doesn't clash controllers,
  // and this instance's own controller gets torn down with the screen
  // instead of leaking in Get's dependency container forever.
  late final String _tag = widget.post.id;

  @override
  void initState() {
    super.initState();
    Get.put(PostDetailController(post: widget.post), tag: _tag);
  }

  @override
  void dispose() {
    Get.delete<PostDetailController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostDetailController>(tag: _tag);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[50],
        elevation: 0,
        title: Text(
          "r/${widget.post.subreddit}",
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [_buildSortButton(controller)],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadComments,
        child: ScreenLayout(
          children: [
            PostField(
              post: widget.post,
              isSinglePost: true,
              safeContentOnly:
                  Get.find<SettingsController>().isSafeContentOnly.value,
            ),
            const SizedBox(height: 8),
            _buildCommentsHeader(controller),
            const Divider(),
            Obx(() {
              if (controller.isLoading.value && controller.comments.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: RedLottieAnim(path: AssetPaths.lottie.loading),
                    ),
                  ),
                );
              }

              if (controller.hasError.value) {
                return _buildError(controller);
              }

              if (controller.comments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      "No comments yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final comment in controller.comments)
                    CommentTile(comment: comment, controller: controller),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsHeader(PostDetailController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${widget.post.numComments} comment${widget.post.numComments == 1 ? '' : 's'}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildError(PostDetailController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            const Text(
              "Couldn't load comments",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: controller.loadComments,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(PostDetailController controller) {
    return Obx(
      () => PopupMenuButton<CommentSortType>(
        tooltip: 'Sort comments',
        initialValue: controller.currentSort.value,
        onSelected: controller.changeSort,
        icon: const Icon(Icons.sort, color: Colors.black87),
        itemBuilder: (context) => CommentSortType.values
            .map(
              (sort) => PopupMenuItem(
                value: sort,
                child: Text(Utility.commentSortTypeDisplayName(sort)),
              ),
            )
            .toList(),
      ),
    );
  }
}
