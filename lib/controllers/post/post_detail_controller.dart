import 'package:get/get.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/models/reddit/reddit_comment_model.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';

class PostDetailController extends GetxController {
  PostDetailController({required this.post});

  final RedditPostModel post;

  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  Rx<CommentSortType> currentSort = CommentSortType.best.obs;

  RxList<RedditCommentModel> comments = <RedditCommentModel>[].obs;

  /// Tracks which comment ids are collapsed (hiding their replies).
  /// Kept separate from the model itself so re-fetching/re-sorting
  /// doesn't force every comment back open.
  final RxSet<String> collapsedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadComments();
  }

  Future<void> loadComments() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final result = await RedditApi.fetchPostComments(
        permalink: post.permalink,
        sortType: currentSort.value,
      );
      if (result == null) {
        hasError.value = true;
        return;
      }
      comments.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  void changeSort(CommentSortType sort) {
    if (sort == currentSort.value) return;
    currentSort.value = sort;
    loadComments();
  }

  void toggleCollapsed(String commentId) {
    if (collapsedIds.contains(commentId)) {
      collapsedIds.remove(commentId);
    } else {
      collapsedIds.add(commentId);
    }
  }

  bool isCollapsed(String commentId) => collapsedIds.contains(commentId);
}
