import 'package:flutter/material.dart';
import 'package:reddy/config/utils/api_callback_listener.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/models/reddit/reddit_user_model.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';

class RedditPostModel {
  // late bool isSelf;
  late PostContentType contentType;
  // late bool isVideo;
  late bool over18;
  late bool spoiler;
  late int ups;
  late int downs;
  late DateTime created;
  late String id;
  late String title;
  late String selftext;
  late String permalink;
  late String author;
  late String subreddit;
  late String url;
  late String domain;
  late RedditImage thumbnail;
  bool isNSFW = false;
  String? postHint;
  bool quarantine = false;
  List<RedditImage> previews = [];
  RedditVideo? video;
  RedditUserModel? user;
  double get aspectRatio {
    if (video != null) {
      return video!.aspectRatio;
    } else if (previews.isNotEmpty) {
      return previews[0].width / previews[0].height;
    } else if (thumbnail.width == 0 || thumbnail.height == 0) {
      return 0.35;
    }
    return thumbnail.width / thumbnail.height;
  }

  RedditPostModel({
    required this.id,
    required this.contentType,
    required this.title,
    required this.selftext,
    required this.ups,
    required this.downs,
    required this.permalink,
    required this.author,
    required this.subreddit,
    required this.over18,
    required this.spoiler,
    required this.quarantine,
    required this.created,
    required this.url,
    required this.domain,
    required this.thumbnail,
    this.postHint,
    this.previews = const [],
    this.video,
    this.user,
  });

  RedditPostModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      title = json['title'];
      selftext = json['selftext'];
      ups = json['ups'];
      downs = json['downs'];
      permalink = json['permalink'];
      author = json['author'];
      subreddit = json['subreddit'];
      over18 = json['over_18'];
      spoiler = json['spoiler'];
      quarantine = json['quarantine'];

      // debugPrint('post: https://reddit.com${json['permalink']} ');
      created = DateTime.fromMillisecondsSinceEpoch(
          json['created_utc'].toInt() * 1000);
      url = json["url_overridden_by_dest"] ?? json['url'];
      domain = json['domain'];
      thumbnail = RedditImage(
        url: json['thumbnail'],
        height: json['thumbnail_height'] ?? 0,
        width: json['thumbnail_width'] ?? 0,
      );
      postHint = json['post_hint'] ?? "self";
      isNSFW = _isNsfwContent(json);
      video = _parseVideo(json);
      if (json['is_self']) {
        contentType = PostContentType.text;
      } else if (json['is_video']) {
        contentType = PostContentType.video;
      } else if (url.endsWith('.gifv') || video != null) {
        contentType = PostContentType.gifv;
      } else if (url.endsWith('.gif')) {
        contentType = PostContentType.gif;
      } else {
        contentType = PostContentType.image;
      }
      // print(contentType);

      previews = contentType == PostContentType.gif
          ? _parseGifPreviews(json)
          : _parseImagePreviews(json);
      updateUserDetails();
    } catch (e) {
      debugPrint('error: $e | $contentType');
    }
  }

  List<RedditImage> _parseGifPreviews(json) {
    // data.children[4].data.preview.images[0].variants.gif
    if (json['preview'] == null ||
        json['preview']['images'] == null ||
        json['preview']['images'][0]['variants'] == null) {
      return [];
    }
    List<RedditImage> res = [];
    json['preview']['images'][0]['variants']['gif']['resolutions'].forEach((v) {
      res.add(RedditImage.fromJson(v));
    });

    return res;
  }

  List<RedditImage> _parseImagePreviews(json) {
    if (json['preview'] == null ||
        json['preview']['images'] == null ||
        json['preview']['images'].length < 1 ||
        json['preview']['images'][0]['resolutions'] == null) {
      return [];
    }
    List<RedditImage> res = [];
    json['preview']['images'][0]['resolutions'].forEach((v) {
      res.add(RedditImage.fromJson(v));
    });
    return res;
  }

  // checking if reddit post contains adult content
  bool _isNsfwContent(json) {
    if (json['over_18'] == true ||
        json['quarantine'] == true ||
        json['whitelist_status'] == "nsfw" ||
        json['thumbnail'] == "nsfw") {
      return true;
    }
    return false;
  }

  RedditVideo? _parseVideo(json) {
    if (json['media'] == null || json['media']['reddit_video'] == null) {
      // return null;
      if (json['preview'] == null ||
          json['preview']['reddit_video_preview'] == null) {
        return null;
      }
      return RedditVideo.fromJson(json['preview']['reddit_video_preview']);
    }
    return RedditVideo.fromJson(json['media']['reddit_video']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // debugPrint('post: https://reddit.com${data['permalink']} ');
    data['id'] = id;
    data['is_self'] = contentType == PostContentType.text;
    data['is_video'] = contentType == PostContentType.video;
    data['title'] = title;
    data['selftext'] = selftext;
    data['ups'] = ups;
    data['downs'] = downs;
    data['permalink'] = permalink;
    data['author'] = author;
    data['subreddit'] = subreddit;
    data['over_18'] = over18;
    data['spoiler'] = spoiler;
    data['quarantine'] = quarantine;
    data['created'] = created;
    data['url'] = url;
    data['domain'] = domain;

    data['thumbnail'] = thumbnail.toJson();
    data['post_hint'] = postHint;
    data['images'] = previews.map((v) => v.toJson()).toList();

    if (video != null) {
      data['video'] = video!.toJson();
    }
    return data;
  }

  void updateUserDetails() async {
    // fetch user details from reddit api
    var res = await RedditApi.fetchUserDetails(
      username: author,
      listener: const ApiCallListener(),
    );
    if (res != null) {
      user = res;
    }
  }
}

class RedditImage {
  late String url;
  late int height;
  late int width;

  RedditImage({
    required this.url,
    required this.height,
    required this.width,
  });

  RedditImage.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    height = json['height'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['height'] = height;
    data['width'] = width;
    return data;
  }
}

class RedditVideo {
  late int height;
  late int width;
  late String hlsUrl;
  late String dashUrl;
  late int duration;
  late String scrubberMediaUrl;

  double get aspectRatio => width / height;
  RedditVideo({
    required this.height,
    required this.width,
    required this.hlsUrl,
    required this.dashUrl,
    required this.duration,
    required this.scrubberMediaUrl,
  });

  RedditVideo.fromJson(Map<String, dynamic> json) {
    height = json['height'];
    width = json['width'];
    hlsUrl = json['hls_url'];
    dashUrl = json['dash_url'];
    duration = json['duration'];
    scrubberMediaUrl = json['scrubber_media_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['width'] = width;
    data['hls_url'] = hlsUrl;
    data['dash_url'] = dashUrl;
    data['duration'] = duration;
    data['scrubber_media_url'] = scrubberMediaUrl;
    return data;
  }
}

// {
//   "id":"",
//   "is_self":false,
//   "is_video":false,
//   "title":"",
//   "selftext":"",
//   "ups":2,
//   "downs":2,
//   "permalink":"",
//   "author":"",
//   "subreddit":"",
//   "over_18":false,
//   "spoiler":false,
//   "quarantine":false,
//   "created":234,
//   "url":"",
//   "domain":"",
//   "thumbnail":{"url":"","height":23,"width":23},
//   // null
//   "post_hint":"",
//   "images":[{"url":"","height":23,"width":23}],
// "video":{
//   "height":23,
//   "width":32,
//   "hls_url":"",
//   "dash_url":"",
//   "duration":12,
//   "scrubber_media_url":""
// }
// }
