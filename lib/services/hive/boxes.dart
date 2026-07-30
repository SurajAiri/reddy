import 'package:hive/hive.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/models/history/reddit_history_model.dart';

class Boxes {
  static Future<Box<RedditHistoryModel>> getHistoryBox() async =>
      await Hive.openBox<RedditHistoryModel>(kHistoryBoxHiveBox);
}
