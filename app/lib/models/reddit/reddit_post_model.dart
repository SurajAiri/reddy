import 'package:flutter/material.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/models/reddit/reddit_user_model.dart';

class RedditPostModel {
  late PostContentType contentType;
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

  /// True for Reddit gallery posts (`reddit.com/gallery/<id>`, or any
  /// post with `is_gallery: true`). These don't have a single
  /// "url_overridden_by_dest" image - instead every image lives in
  /// `media_metadata` keyed by the ids listed in `gallery_data`.
  bool isGallery = false;

  /// All images belonging to a gallery post, in the order Reddit
  /// wants them displayed. Empty for non-gallery posts.
  List<RedditImage> galleryImages = [];

  RedditVideo? video;
  RedditUserModel? user;

  double get aspectRatio {
    if (video != null) {
      return video!.aspectRatio;
    } else if (previews.isNotEmpty) {
      return previews[0].width / previews[0].height;
    } else if (isGallery && galleryImages.isNotEmpty) {
      return galleryImages[0].width / galleryImages[0].height;
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
    this.isGallery = false,
    this.galleryImages = const [],
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

      created = DateTime.fromMillisecondsSinceEpoch(
          json['created_utc'].toInt() * 1000);
      url = json["url_overridden_by_dest"] ?? json['url'] ?? '';
      domain = json['domain'] ?? '';
      thumbnail = RedditImage(
        url: json['thumbnail'] ?? '',
        height: json['thumbnail_height'] ?? 0,
        width: json['thumbnail_width'] ?? 0,
      );
      postHint = json['post_hint'] ?? "self";
      isNSFW = _isNsfwContent(json);
      video = _parseVideo(json);

      isGallery = json['is_gallery'] == true || _isGalleryUrl(url);
      galleryImages = isGallery ? _parseGalleryImages(json) : [];

      if (json['is_self'] == true) {
        contentType = PostContentType.text;
      } else if (json['is_video'] == true) {
        contentType = PostContentType.video;
      } else if (isGallery && galleryImages.isNotEmpty) {
        contentType = PostContentType.image;
      } else if (url.endsWith('.gifv') || video != null) {
        contentType = PostContentType.gifv;
      } else if (url.endsWith('.gif')) {
        contentType = PostContentType.gif;
      } else {
        contentType = PostContentType.image;
      }

      previews = contentType == PostContentType.gif
          ? _parseGifPreviews(json)
          : _parseImagePreviews(json);

      // Fall back to the (single) gallery cover image for the aspect
      // ratio / thumbnail-style consumers that only look at `previews`,
      // while `galleryImages` carries the full set for the carousel UI.
      if (previews.isEmpty && isGallery && galleryImages.isNotEmpty) {
        previews = [galleryImages.first];
      }

      // NOTE: user profile details (avatar, karma, etc.) are
      // intentionally NOT fetched here anymore. Doing it eagerly for
      // every single post as soon as a feed page is parsed used to
      // fire one extra HTTP request per post (25 posts = 25 requests)
      // regardless of whether that post was ever scrolled into view,
      // which was slow, wasteful on data/battery, and a common cause
      // of Reddit rate-limiting. It's now fetched lazily (and cached)
      // by the widget that actually renders the author avatar.
    } catch (e) {
      debugPrint('error parsing post: $e');
    }
  }

  bool _isGalleryUrl(String url) => url.contains('/gallery/');

  List<RedditImage> _parseGifPreviews(json) {
    if (json['preview'] == null ||
        json['preview']['images'] == null ||
        json['preview']['images'].isEmpty ||
        json['preview']['images'][0]['variants'] == null ||
        json['preview']['images'][0]['variants']['gif'] == null) {
      return [];
    }
    List<RedditImage> res = [];
    json['preview']['images'][0]['variants']['gif']['resolutions']
        .forEach((v) {
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

  /// Parses Reddit gallery posts. Gallery posts store their images in
  /// `media_metadata` (keyed by media id) with the display order given
  /// by `gallery_data.items`. This is what lets `reddit.com/gallery/<id>`
  /// style posts actually render instead of showing a dead link - the
  /// old code only ever looked at `preview.images`, which for gallery
  /// posts is often missing or only reflects a single image.
  List<RedditImage> _parseGalleryImages(json) {
    try {
      final metadata = json['media_metadata'];
      final galleryData = json['gallery_data'];
      if (metadata == null ||
          galleryData == null ||
          galleryData['items'] == null) {
        return [];
      }

      List<RedditImage> result = [];
      for (final item in galleryData['items']) {
        final mediaId = item['media_id'];
        final meta = metadata[mediaId];
        if (meta == null || meta['status'] != 'valid') continue;

        final source = meta['s'];
        if (source == null) continue;

        // Static images use `u`; animated gallery items may only have
        // `gif` or `mp4` variants.
        final rawUrl = source['u'] ?? source['gif'] ?? source['mp4'];
        if (rawUrl == null) continue;

        result.add(RedditImage(
          url: rawUrl.toString().replaceAll('&amp;', '&'),
          width: _toInt(source['x']),
          height: _toInt(source['y']),
        ));
      }
      return result;
    } catch (e) {
      debugPrint('error parsing gallery: $e');
      return [];
    }
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
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
    data['created'] = created.toIso8601String();
    data['url'] = url;
    data['domain'] = domain;

    data['thumbnail'] = thumbnail.toJson();
    data['post_hint'] = postHint;
    data['images'] = previews.map((v) => v.toJson()).toList();
    data['is_gallery'] = isGallery;
    data['gallery_images'] = galleryImages.map((v) => v.toJson()).toList();

    if (video != null) {
      data['video'] = video!.toJson();
    }
    return data;
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
