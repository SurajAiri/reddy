enum ImageQuality { lowest, low, mediumLow, medium, mediumHigh, high, highest }

enum PostContentType { image, gif, gifv, video, text }

enum RedditSortType { hot, new_, rising, top, controversial, best }

/// Sort options accepted by reddit's comment listing endpoint
/// (`/comments/<id>.json?sort=...`). This is a DIFFERENT set of
/// values than [RedditSortType] - comments have no `hot`/`rising`,
/// but do have `old`/`qa`, which posts don't.
enum CommentSortType { best, top, new_, controversial, old, qa }
