import 'package:hive/hive.dart';
import 'package:reddy/models/history/reddit_history_model.dart';

import '../../config/utils/constants.dart';
import 'boxes.dart';

class RedditHistoryHiveStorage {
  static void addHistory(RedditHistoryModel value,
      {Function()? onComplete}) async {
    print('call for adding');
    Box<RedditHistoryModel> box = await Boxes.getHistoryBox().then((value) {
      if (onComplete != null) {
        onComplete();
      }
      return value;
    });
    box.add(value);
    // box.add(RedditHistoryModel(value: "value"));
    print("we have added history");
  }

  static Future<void> clearHistory() async {
    Box<RedditHistoryModel> box = await Boxes.getHistoryBox();
    await box.clear();
  }

  static void updateHistory(RedditHistoryModel meme) {
    meme.save();
  }

  static void deleteHistory(RedditHistoryModel meme) {
    meme.delete();
  }

  static Future<List<RedditHistoryModel>> getAllHistory(
      {String? search}) async {
    Box<RedditHistoryModel> box = await Boxes.getHistoryBox();
    var v = box.values.skip(box.length > kMaxFavHistoryLimit
        ? box.length - kMaxFavHistoryLimit
        : 0);
    print("search value is $search");
    if (search != null) {
      print("we got a call");
      v = v.where((element) =>
          element.value.toLowerCase().contains(search.toLowerCase()));
    } else {
      print("this should not happen");
    }

    var t = v.take(kMaxFavHistoryLimit).toList();
    print("we got ${t.length} history");
    t.sort((a, b) => a.lastSearchDate.compareTo(b.lastSearchDate));
    t = t.reversed.toList();
    return t;
  }

  static Future<bool> checkIfHistoryExists(String title) async {
    Box<RedditHistoryModel> box = await Boxes.getHistoryBox();
    var val = box.values
        .where((element) => element.value.toLowerCase() == title.toLowerCase())
        .toList();
    if (val.isEmpty) return false;
    return true;
  }

  // static Future<RedditHistoryModel?> getIfHistoryExists(String title) async {
  //   Box<RedditHistoryModel> box = await Boxes.getHistoryBox();
  //   var val = box.values
  //       .where((element) => element.value.toLowerCase() == title.toLowerCase())
  //       .toList();
  //   if (val.isEmpty) return null;
  //   return val[0];
  // }
}
