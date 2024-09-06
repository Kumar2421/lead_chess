import "dart:convert";
List<Reward> welcomeFromJson(String str) =>
    List<Reward>.from(json.decode(str).map((x) => Reward.fromJson(x)));

String welcomeToJson(List<Reward> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reward {
  String id;
  String userId;
  String totalRewardAmount;
  Reward({
    required this.id,
    required this.userId,
    required this.totalRewardAmount
  });

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
      id: json["log_id"] ?? "",
      userId: json["user_id"] ?? "",
      totalRewardAmount: json["reward_amount"] ?? ""
  );

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['log_id'] = id;
  data['user_id'] =  userId;
  data['reward_amount'] = totalRewardAmount;
   return data;
  }

}

