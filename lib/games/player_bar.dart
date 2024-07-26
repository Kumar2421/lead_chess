// import 'package:flutter/material.dart';
// import 'piece_widget.dart';
//
// import 'package:get_it/get_it.dart';
// import 'game_logic.dart';
// final logic = GetIt.instance<GameLogic>();
//
// class PlayerBar extends StatelessWidget {
//   final bool isMe;
//   final PieceColor color;
//
//   const PlayerBar(
//       this.isMe,
//       this.color, {
//         super.key,
//       });
//
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     // Determine if the device is a tablet
//     bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
//
//     // Set the height and width based on the device type
//     double containerHeight = isTablet ? screenHeight / 13 : screenHeight / 9;
//     double containerWidth = screenWidth;
//
//     final isMyTurn = color == logic.turn();
//     final pieceScore = logic.getRelScore(color);
//     final eaten = color == PieceColor.WHITE ? logic.eatenBlack : logic.eatenWhite;
//
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 4.0),
//       height: containerHeight,
//       width: containerWidth,
//       decoration: BoxDecoration(
//         color: Theme.of(context).dividerColor,
//       ),
//       child: Row(
//         children: [
//           Image.asset(
//             'assets/c4.jpeg',
//             height: 50,
//             width: 50, // Set the width same as height for square image
//           ),
//           Expanded(
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: eaten
//                   .map((pieceType) => SizedBox(
//                 width: screenWidth / 15,
//                 height: screenHeight / 15,
//                 child: PieceWidget(piece: Piece(pieceType, color)),
//               ))
//                   .toList(),
//             ),
//           ),
//
//         ],
//       ),
//     );
//   }
// }
// class PlayerBar2 extends StatelessWidget {
//   final bool isMe;
//   final PieceColor color;
//
//   const PlayerBar2(
//       this.isMe,
//       this.color, {
//         super.key,
//       });
//
//   @override
//   Widget build(BuildContext context) {
//     final isMyTurn = color == logic.turn();
//     final pieceScore = logic.getRelScore(color);
//     final eaten = color == PieceColor.WHITE ? logic.eatenBlack : logic.eatenWhite;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       decoration: BoxDecoration(
//         color: Theme.of(context).dividerColor,
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Image.asset(
//                 'assets/c4.jpeg',
//                 height: 30,
//                 width: 30,
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(minHeight: 30),
//               child: Wrap(
//                 children: eaten
//                     .map((pieceType) => SizedBox(
//                   width: 31,
//                   height: 31,
//                   child: PieceWidget(piece: Piece(pieceType, color)),
//                 ))
//                     .toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'piece_widget.dart';

import 'package:get_it/get_it.dart';
import 'game_logic.dart';
final logic = GetIt.instance<GameLogic>();

class PlayerBar extends StatelessWidget {
  final bool isMe;
  final PieceColor color;

  const PlayerBar(
      this.isMe,
      this.color, {
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Determine if the device is a tablet
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // Set the height and width based on the device type
    double containerHeight = isTablet ? screenHeight / 13 : screenHeight / 9;
    double containerWidth = screenWidth;

    final isMyTurn = color == logic.turn();
    final pieceScore = logic.getRelScore(color);
    final eaten = color == PieceColor.WHITE ? logic.eatenBlack : logic.eatenWhite;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      height: containerHeight,
      width: containerWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: eaten
                  .map((pieceType) => SizedBox(
                width: screenWidth / 15,
                height: screenHeight / 15,
                child: PieceWidget(piece: Piece(pieceType, color)),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}


class PlayerBar2 extends StatelessWidget {
  final bool isMe;
  final PieceColor color;
  const PlayerBar2(
      this.isMe,
      this.color,
      {super.key }
      );

  @override
  Widget build(BuildContext context) {
    final isMyTurn = color == (logic.turn());
    final pieceScore = logic.getRelScore(color);
    final eaten = color == PieceColor.WHITE ? logic.eatenBlack : logic.eatenWhite;  //change the black to white
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
          color: Theme.of(context).dividerColor
      ),
      child: ListView(
          primary: false,
          shrinkWrap: true,
          children: [
            Text(
                (isMe ? "Computer" : "You") + (pieceScore > 0 ? " +$pieceScore" : ""),
                style: TextStyle(fontWeight: isMyTurn ? FontWeight.bold : FontWeight.normal, fontSize: 20)
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 30),
                child: Wrap(
                    children: eaten
                        .map((pieceType) => SizedBox(
                        width: 31,
                        height: 31,
                        child: PieceWidget(piece: Piece(pieceType, color))
                    ))
                        .toList()
                ),
              ),
            )
          ]
      ),
    );
  }
}