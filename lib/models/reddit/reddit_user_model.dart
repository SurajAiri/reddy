class RedditUserModel {
  late DateTime created;
  late String id;
  late bool verified;
  late String name;
  late String iconImg;
  late int totalKarma;
  bool isGold = false;
  bool isMod = false;
  RedditUserModel({
    required this.id,
    required this.created,
    required this.verified,
    required this.name,
    required this.iconImg,
    required this.totalKarma,
    this.isGold = false,
    this.isMod = false,
  });

  RedditUserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    created =
        DateTime.fromMillisecondsSinceEpoch(json['created_utc'].toInt() * 1000);
    verified = json['verified'];
    name = json['name'];
    iconImg = json['icon_img'].toString().split('?')[0];
    print(iconImg);
    totalKarma = json['total_karma'];
    isGold = json['is_gold'];
    isMod = json['is_mod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created'] = created;
    data['verified'] = verified;
    data['name'] = name;
    data['icon_img'] = iconImg;
    data['total_karma'] = totalKarma;
    data['is_gold'] = isGold;
    data['is_mod'] = isMod;
    return data;
  }
}


// {
//   "id":"",
//   "created":0,
//   "verified":false,
//   "name":"",
//   "icon_img":"",
//   "total_karma":123
// }