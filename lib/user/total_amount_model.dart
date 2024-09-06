import 'dart:convert';

List<TotalAmount> welcomeFromJson(String str) =>
    List<TotalAmount>.from(jsonDecode(str).map((x)=> TotalAmount.fromJson(x)));

String welcomeToJson(List<TotalAmount> data)=>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TotalAmount{
  String id;
  String userId;
  String totalRewardAmount;
  String totalMoney;
  TotalAmount({
    required this.id,
    required this.userId,
    required this.totalRewardAmount,
    required this.totalMoney
  });
  factory TotalAmount.fromJson(Map<String,dynamic> json) => TotalAmount(
      id: json["id"] ?? "",
      userId: json["user_id"] ?? "",
      totalRewardAmount: json["total_amount"] ?? "",
      totalMoney: json["total_money"] ??""
  );
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['log_id'] = id;
    data['user_id'] =  userId;
    data['total_amount'] = totalRewardAmount;
    data['total_money'] = totalMoney;
    return data;
  }
}