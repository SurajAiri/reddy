class SubredditModel {
  final String name;
  final String iconUrl;
  final int subscribers;

  SubredditModel({
    required this.name,
    this.iconUrl = 'https://www.redditstatic.com/desktop2x/img/favicon/android-icon-192x192.png',
    this.subscribers = 0,
  });

  factory SubredditModel.fromJson(Map<String, dynamic> json) {
    return SubredditModel(
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String? ?? 'https://www.redditstatic.com/desktop2x/img/favicon/android-icon-192x192.png',
      subscribers: json['subscribers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon_url': iconUrl,
      'subscribers': subscribers,
    };
  }

  @override
  String toString() {
    return 'Subreddit{name: $name, subscribers: $subscribers, iconUrl: $iconUrl}';
  }
}