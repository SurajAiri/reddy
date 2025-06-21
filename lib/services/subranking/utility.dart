
enum SubrankingType {
  largest,
  weekly,
  random,
}
enum SubrankingCategory {
  sfw,
  nsfw,
  nonVerify,
  karmaFriendly,
}

class SubrankingUtility {
  static String getSubrankingTypeString(SubrankingType type) {
    switch (type) {
      case SubrankingType.largest:
        return "largest";
      case SubrankingType.weekly:
        return "weekly";
      case SubrankingType.random:
        return "random";
    }
  }

  static String getSubrankingCategoryString(SubrankingCategory category) {
    switch (category) {
      case SubrankingCategory.sfw:
        return "sfw";
      case SubrankingCategory.nsfw:
        return "nsfw";
      case SubrankingCategory.nonVerify:
        return "non_verify";
      case SubrankingCategory.karmaFriendly:
        return "karma_friendly";
    }
  }
}