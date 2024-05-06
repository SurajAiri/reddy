import 'package:flutter/material.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';
import 'package:reddy/views/features/general/widgets/post_field.dart';
import 'package:reddy/views/widgets/screen_layout.dart';

class SinglePostScreen extends StatelessWidget {
  const SinglePostScreen({super.key, required this.post});
  final RedditPostModel post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenLayout(
        children: [
          PostField(
            post: post,
            isSinglePost: true,
          ),
        ],
      ),
    );
  }
}
