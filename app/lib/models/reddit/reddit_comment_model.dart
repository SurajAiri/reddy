import 'package:flutter/foundation.dart';

enum CommentBodyPartType { text, gif }

/// One chunk of a comment's body: either plain text or a gif to
/// render inline. See [RedditCommentModel.bodyParts].
class CommentBodyPart {
  final CommentBodyPartType type;
  final String text;
  final String? gifUrl;

  const CommentBodyPart.text(this.text)
      : type = CommentBodyPartType.text,
        gifUrl = null;

  const CommentBodyPart.gif(this.gifUrl)
      : type = CommentBodyPartType.gif,
        text = '';
}

/// A single node in a reddit comment tree.
///
/// Reddit's `/comments/<id>.json` response nests replies recursively
/// inside `data.replies.data.children`, and mixes in `kind: "more"`
/// stubs (a "load N more replies" marker) among the real `kind: "t1"`
/// comments whenever a thread is deeper/wider than the API wants to
/// send in one shot. We flatten each "more" stub into a lightweight
/// placeholder node (see [isMoreStub]) rather than dropping that
/// information on the floor, so the UI can at least tell the user
/// there's more to see instead of silently truncating the thread.
///
/// NOTE: actually *fetching* those extra replies would require a
/// second call to reddit's `api/morechildren` endpoint (different
/// request shape, comma-separated id list, etc.) - that's not wired
/// up here. A stub just tells you it exists; tapping it does nothing
/// yet. Flagging this explicitly instead of faking a working button.
class RedditCommentModel {
  final String id;
  final String author;
  final String body;
  final int score;
  final bool scoreHidden;
  final DateTime created;
  final int depth;
  final bool isSubmitter;
  final bool stickied;
  final String? distinguished; // 'moderator' | 'admin' | null
  final List<RedditCommentModel> replies;

  /// True for a "more" stub instead of a real comment.
  final bool isMoreStub;

  /// Only meaningful when [isMoreStub] is true - how many additional
  /// replies exist at this point in the thread that weren't sent.
  final int moreCount;

  RedditCommentModel({
    required this.id,
    required this.author,
    required this.body,
    required this.score,
    required this.scoreHidden,
    required this.created,
    required this.depth,
    this.isSubmitter = false,
    this.stickied = false,
    this.distinguished,
    this.replies = const [],
    this.isMoreStub = false,
    this.moreCount = 0,
  });

  factory RedditCommentModel._moreStub({
    required int depth,
    required int count,
  }) {
    return RedditCommentModel(
      id: 'more_${depth}_$count',
      author: '',
      body: '',
      score: 0,
      scoreHidden: false,
      created: DateTime.fromMillisecondsSinceEpoch(0),
      depth: depth,
      isMoreStub: true,
      moreCount: count,
    );
  }

  factory RedditCommentModel.fromJson(Map<String, dynamic> json) {
    final createdUtc = json['created_utc'];
    final depth = _toInt(json['depth']);
    return RedditCommentModel(
      id: json['id']?.toString() ?? '',
      author: json['author']?.toString() ?? '[deleted]',
      // Reddit sends the literal string "[deleted]"/"[removed]" here
      // for gone comments already, so no extra handling needed.
      body: json['body']?.toString() ?? '',
      score: json['score_hidden'] == true ? 0 : _toInt(json['score']),
      scoreHidden: json['score_hidden'] == true,
      created: createdUtc == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(_toInt(createdUtc) * 1000),
      depth: depth,
      isSubmitter: json['is_submitter'] == true,
      stickied: json['stickied'] == true,
      distinguished: json['distinguished']?.toString(),
      replies: _parseReplies(json['replies'], depth),
    );
  }

  /// Reddit's built-in Giphy picker writes gifs into the comment
  /// `body` as raw markdown - `![gif](giphy|<id>)`, sometimes with a
  /// trailing `|<size>` - instead of a resolvable media reference.
  /// Nothing upstream ever turned that into an actual image, so it
  /// was rendering as literal `![gif](giphy|...)` text in the UI.
  /// The id maps directly to Giphy's CDN, no extra API call needed.
  static final RegExp _giphyEmbedPattern =
      RegExp(r'!\[gif\]\(giphy\|([a-zA-Z0-9]+)(?:\|[^)]*)?\)');

  /// Splits [body] into plain-text and gif segments in order, so the
  /// UI can render a real image for the gif part instead of dumping
  /// the markdown source as text.
  List<CommentBodyPart> get bodyParts {
    final parts = <CommentBodyPart>[];
    int cursor = 0;
    for (final match in _giphyEmbedPattern.allMatches(body)) {
      if (match.start > cursor) {
        final text = body.substring(cursor, match.start).trim();
        if (text.isNotEmpty) parts.add(CommentBodyPart.text(text));
      }
      final gifId = match.group(1)!;
      parts.add(
        CommentBodyPart.gif('https://i.giphy.com/media/$gifId/giphy.gif'),
      );
      cursor = match.end;
    }
    if (cursor < body.length) {
      final text = body.substring(cursor).trim();
      if (text.isNotEmpty) parts.add(CommentBodyPart.text(text));
    }
    // Body was pure whitespace/empty (or nothing but a gif with no
    // surrounding text is already covered above) - nothing to add.
    return parts;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  /// `replies` is either `""` (no replies at all) or a `Listing`
  /// object whose `data.children` is the next level of the tree.
  static List<RedditCommentModel> _parseReplies(dynamic repliesJson, int parentDepth) {
    if (repliesJson is! Map) return [];
    try {
      final children = repliesJson['data']?['children'] as List?;
      if (children == null) return [];
      return _parseChildren(children, parentDepth + 1);
    } catch (e) {
      debugPrint('error parsing comment replies: $e');
      return [];
    }
  }

  static List<RedditCommentModel> _parseChildren(List children, int depth) {
    final result = <RedditCommentModel>[];
    for (final child in children) {
      final kind = child['kind'];
      final data = child['data'];
      if (data == null) continue;
      if (kind == 'more') {
        final ids = data['children'] as List?;
        final count = _toInt(data['count'] ?? ids?.length ?? 0);
        if (count <= 0) continue;
        result.add(RedditCommentModel._moreStub(depth: depth, count: count));
      } else if (kind == 't1') {
        result.add(RedditCommentModel.fromJson(data));
      }
    }
    return result;
  }

  /// Parses the top-level comment listing - the SECOND element of the
  /// two-element array reddit's `/comments/<id>.json` returns (the
  /// first element is just the post itself, which we already have).
  static List<RedditCommentModel> listFromCommentsListing(
    Map<String, dynamic>? commentsListingJson,
  ) {
    if (commentsListingJson == null) return [];
    try {
      final children = commentsListingJson['data']?['children'] as List?;
      if (children == null) return [];
      return _parseChildren(children, 0);
    } catch (e) {
      debugPrint('error parsing comments listing: $e');
      return [];
    }
  }
}
