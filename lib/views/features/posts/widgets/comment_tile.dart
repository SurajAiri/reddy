import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/link_handler.dart';
import 'package:reddy/controllers/post/post_detail_controller.dart';
import 'package:reddy/models/reddit/reddit_comment_model.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Renders a single comment plus (recursively) all of its replies.
/// Indentation is capped past a certain depth - reddit threads can
/// nest 10+ levels deep, and letting padding grow unbounded eventually
/// leaves no room for the actual text on a phone-width screen.
class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment, required this.controller});
  final RedditCommentModel comment;
  final PostDetailController controller;

  static const int _maxIndentDepth = 8;
  static const double _indentPerLevel = 12.0;

  @override
  Widget build(BuildContext context) {
    if (comment.isMoreStub) return _buildMoreStub();

    // Top-level comments get their own card. Previously every comment
    // - related or not - ran together in one continuous block with no
    // visual separation, so a busy thread just looked like a wall of
    // text. Grouping each top-level comment (and everything nested
    // under it) into a card matches the same visual language as
    // PostField and makes each conversation scannable at a glance.
    if (comment.depth == 0) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: _buildBody(context),
      );
    }

    final indent = _indentPerLevel * comment.depth.clamp(0, _maxIndentDepth);
    final railColor = _railColor(comment.depth);

    return Padding(
      padding: EdgeInsets.only(left: indent, top: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: railColor, width: 2)),
        ),
        padding: const EdgeInsets.only(left: 10),
        child: _buildBody(context),
      ),
    );
  }

  /// Depth communicated by shade, not hue. The old version cycled
  /// through 4 unrelated colours by `depth % 4`, so two completely
  /// separate threads at depth 4 and depth 8 rendered in the exact
  /// same colour - implying a relationship between them that doesn't
  /// exist. A monotonic shade at least means "darker = deeper", which
  /// is actually true.
  Color _railColor(int depth) {
    final shade = (300 + (depth.clamp(0, 4) * 60)).clamp(300, 600).toInt();
    return Colors.blueGrey[shade] ?? Colors.blueGrey;
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      final collapsed = controller.isCollapsed(comment.id);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => controller.toggleCollapsed(comment.id),
            child: _buildHeader(collapsed),
          ),
          if (!collapsed) ...[
            const SizedBox(height: 4),
            _buildContent(context),
            for (final reply in comment.replies)
              CommentTile(comment: reply, controller: controller),
          ] else
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${comment.replies.length} repl${comment.replies.length == 1 ? 'y' : 'ies'} hidden",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
        ],
      );
    });
  }

  /// Body split into text/gif parts - see [RedditCommentModel.bodyParts].
  /// Text parts are markdown source (bold, italics, links, etc.) -
  /// previously rendered with a plain `Text()`, so e.g. `[link](url)`
  /// showed up as the literal characters `[link](url)` instead of a
  /// tappable link. `MarkdownBody` actually parses it.
  Widget _buildContent(BuildContext context) {
    final parts = comment.bodyParts;
    if (parts.isEmpty) return const SizedBox.shrink();

    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: const TextStyle(fontSize: 14, height: 1.35, color: Color(0xFF1A1A1A)),
      a: TextStyle(color: Colors.blue[700], decoration: TextDecoration.underline),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final part in parts)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: part.type == CommentBodyPartType.gif
                ? _CommentGif(url: part.gifUrl!)
                : MarkdownBody(
                    data: part.text,
                    selectable: false,
                    softLineBreak: true,
                    styleSheet: styleSheet,
                    onTapLink: (text, href, title) {
                      if (href != null) LinkHandler.open(href);
                    },
                  ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool collapsed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          collapsed ? Icons.chevron_right_rounded : Icons.expand_more_rounded,
          size: 18,
          color: Colors.grey,
        ),
        Text(
          comment.author,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: comment.isSubmitter
                ? Colors.blue
                : comment.distinguished == 'moderator'
                    ? Colors.green
                    : comment.distinguished == 'admin'
                        ? Colors.red
                        : Colors.black87,
          ),
        ),
        if (comment.isSubmitter) ...[
          const SizedBox(width: 4),
          const _Tag(text: "OP", color: Colors.blue),
        ],
        if (comment.distinguished == 'moderator') ...[
          const SizedBox(width: 4),
          const _Tag(text: "MOD", color: Colors.green),
        ],
        const SizedBox(width: 6),
        Icon(Icons.arrow_upward_rounded, size: 11, color: Colors.grey.shade500),
        Text(
          comment.scoreHidden ? " hidden" : " ${comment.score}",
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(width: 6),
        Text(
          "• ${timeago.format(comment.created.toLocal())}",
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  /// Reddit truncates very wide/deep threads and hands back a "more"
  /// stub instead of the actual comments. There's no fetch wired up
  /// for it (see reddit_comment_model.dart) - this is intentionally
  /// inert, just honest about what's missing instead of a dead button
  /// pretending to work.
  Widget _buildMoreStub() {
    final indent = _indentPerLevel * comment.depth.clamp(0, _maxIndentDepth);
    return Padding(
      padding: EdgeInsets.only(left: indent, top: 6, bottom: 6),
      child: Text(
        "${comment.moreCount} more repl${comment.moreCount == 1 ? 'y' : 'ies'} not loaded",
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

/// Renders a Giphy gif embedded in a comment body. The URL is already
/// resolved to a direct i.giphy.com link by
/// [RedditCommentModel.bodyParts] - this widget just displays it with
/// a height cap so a single gif can't blow out the whole thread's
/// layout, loading/error states via [CachedNetworkImage].
class _CommentGif extends StatelessWidget {
  const _CommentGif({required this.url});
  final String url;

  static const double _maxHeight = 220;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _maxHeight),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          placeholder: (context, url) => Container(
            height: 120,
            width: 120,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.broken_image_outlined, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text("gif failed to load", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
