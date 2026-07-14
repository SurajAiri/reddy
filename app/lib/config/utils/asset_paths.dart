class AssetPaths {
  static final img = _ImagePaths();
  static final lottie = _LottiePaths();
  static final data = _DataPaths();
}

class _ImagePaths {
  final String logo = 'assets/icon/icon.png';
}

class _LottiePaths {
  final String validation = 'assets/lottie/reddit_validating.json';
  final String loading = 'assets/lottie/loading.json';
}

class _DataPaths {
  final String sfwSubreddit = 'assets/data/data_sfw.json';
  final String nsfwSubreddit = 'assets/data/data_nsfw.json';
}
