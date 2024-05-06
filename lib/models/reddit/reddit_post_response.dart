import 'reddit_post_model.dart';

class RedditPostResponse {
  late String subreddit;
  String? before;
  String? after;
  List<RedditPostModel> posts = [];

  RedditPostResponse({
    required this.subreddit,
    this.posts = const [],
    this.before,
    this.after,
  });

  factory RedditPostResponse.fromJson(
      {required String subreddit, required Map<String, dynamic> json}) {
    return RedditPostResponse(
      subreddit: subreddit,
      posts: List<RedditPostModel>.from(
        json['data']['children'].map(
          (v) => RedditPostModel.fromJson(v['data']),
        ),
      ),
      before: json['data']['before'],
      after: json['data']['after'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subreddit'] = subreddit;
    data['before'] = before;
    data['after'] = after;
    data['posts'] = posts.map((v) => v.toJson()).toList();
    return data;
  }
}
