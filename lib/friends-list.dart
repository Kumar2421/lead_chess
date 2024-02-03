import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
class FriendsList extends StatelessWidget {
  final String child;
  const FriendsList({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
          height: screenHeight/12,
        width: screenWidth/1.2,
        color: color.navy1.withOpacity(0.15),
        child: Text(child,style: TextStyle(fontSize: 20), ),
      ),
    );
  }
}
