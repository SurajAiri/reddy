import 'package:hive/hive.dart';

part 'reddit_history_model.g.dart';

@HiveType(typeId: 1)
class RedditHistoryModel extends HiveObject {
  RedditHistoryModel({
    required this.value,
    this.searchCount = 1,
    this.safe = true,
  }) {
    updateChangeDate();
  }

  @HiveField(0)
  String value = "";
  @HiveField(1)
  int searchCount = 0;
  @HiveField(2)
  int lastSearchDate = DateTime.now().millisecondsSinceEpoch;
  @HiveField(3)
  bool safe = true;

  void incrementCount() {
    searchCount++;
    updateChangeDate();
  }

  void updateChangeDate() {
    lastSearchDate = DateTime.now().millisecondsSinceEpoch;
  }

  RedditHistoryModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    searchCount = json['searchCount'];
    lastSearchDate = json['last_search'];
    safe = json['safe'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['value'] = value;
    data['searchCount'] = searchCount;
    data['last_search'] = lastSearchDate;
    data['safe'] = safe;
    return data;
  }
}

// {
//   "value":"reddit",
//   "searchCount": 1,
//   "last_search": 1234
// }