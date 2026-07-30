class RedditInfoModel {
  final Uri site;
  String? cookies;
  String? ua;

  /// When these credentials were captured/refreshed. Used to show
  /// "last login" info to the user and to decide when a re-auth
  /// might be a good idea.
  DateTime loggedInAt;

  RedditInfoModel(
    this.site,
    this.cookies,
    this.ua, {
    DateTime? loggedInAt,
  }) : loggedInAt = loggedInAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'site': site.toString(),
        'cookies': cookies,
        'ua': ua,
        'loggedInAt': loggedInAt.toIso8601String(),
      };

  factory RedditInfoModel.fromJson(Map<String, dynamic> json) {
    return RedditInfoModel(
      Uri.parse(json['site'] as String),
      json['cookies'] as String?,
      json['ua'] as String?,
      loggedInAt: json['loggedInAt'] != null
          ? DateTime.tryParse(json['loggedInAt'] as String)
          : null,
    );
  }
}
