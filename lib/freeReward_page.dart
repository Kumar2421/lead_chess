import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:chess_game/screen/homepage.dart';
import 'package:chess_game/spin_wheel.dart';
import 'package:chess_game/user/current_user.dart';
import 'package:chess_game/user/total_amount_model.dart';
import 'package:chess_game/user/users.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'colors.dart';


class FreeReward extends StatefulWidget {
  final void Function(GlobalKey)? onClick;
  final double borderSize;
  final Color borderColor;
  FreeReward({super.key, required this.onClick, this.borderSize = 5.0,
    this.borderColor = color.blue3,});

  @override
  _FreeRewardState createState() => _FreeRewardState();
}

class _FreeRewardState extends State<FreeReward> {
  final GlobalKey widgetKey = GlobalKey();
  late Timer _timer;
  final double _scaleFactor = 1.0;
  int totalRewardAmount = 10;
  int totalMoney = 0;
  int rewardedCount = 0;
  Users currentUser = Get.find<CurrentUser>().users;
  late TotalAmount totalAmount = TotalAmount(
    id: "",
    userId: "",
    totalRewardAmount: "",
    totalMoney: "",
  );

  Future<TotalAmount?> insertIntoCoinsTable(String userId, int totalRewardAmount, int totalMoney,) async {
    try {
      var url = Uri.parse('https://schmidivan.com/Esakki/ChessGame/free_coins');
      var body = {
        'user_id': userId,
        'total_amount': totalRewardAmount.toString(),
        'total_money': totalMoney.toString(),
      };

      var response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        print('Data inserted into coins table successfully');
        return TotalAmount.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to insert data into coins table: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error inserting data into coins table: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize _timer with a dummy timer to avoid LateInitializationError
    _timer = Timer(Duration(seconds: 0), () {});
    //  _loadState();
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return BouncingWidget(
      scaleFactor: _scaleFactor,
      onPressed: (){},
      child: ClipPath(
        clipper: ParallelogramClipper(),
        child:  Container(
          height: screenHeight / 15,
          width: screenWidth / 3.5,
          decoration: BoxDecoration(
            color: color.navy1,
            border: Border.all(
              color: widget.borderColor,
              width: widget.borderSize,
            ),
            // borderRadius: BorderRadius.circular(10),
            //  border: Border.all(
            //      color: color.navy.withOpacity(0.99), width: 10.0
            //  ),
          ),
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (timerService.rewardDialogTimerActive)
                Text(
                  _formatDuration(timerService.rewardDialogRemainingTime),
                  style: TextStyle(fontSize: 30,color: Colors.white),
                )
              else
                ClipPath(
                  clipper: ParallelogramClipper(),
                  child: Container(
                    height: screenHeight/20,
                    width: screenWidth/4.5,
                    child: MaterialButton(
                      onPressed: () async {
                        widget.onClick!(widgetKey);
                        timerService.startRewardDialogTimer(Duration(minutes: 1));
                        await insertIntoCoinsTable(currentUser.userId, totalRewardAmount, totalMoney);
                      },
                      color: Colors.orange,
                      child: Row(
                        children: [
                          const Text(
                            '10',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          GestureDetector(
                           // onTap: () => widget.onClick!(widgetKey),
                            child: Container(
                              key: widgetKey,
                              child: Image(
                                image: AssetImage('assets/Dollar.png'),  width: screenWidth/20, height: screenHeight/15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
