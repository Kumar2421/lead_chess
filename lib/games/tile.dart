import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'piece_widget.dart';
import 'dart:math' as math;
import 'package:chess/chess.dart' as chess_lib;

import 'package:get_it/get_it.dart'; 
import 'game_logic.dart'; 
final logic = GetIt.instance<GameLogic>();

class Tile extends StatelessWidget {
  final chess_lib.Piece? piece;
  final String tileColor;
  final String index;

  Tile({super.key, required this.index})
      : piece = logic.get(index),
        tileColor = logic.squareColor(index)!;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    var labelStyle =
    TextStyle(color: tileColor == 'light' ? Colors.black : Colors.white);
    final args = logic.args;
    final fileLabel = args.asBlack
        ? (index[1] == "" ? index[0] : "")
        : (index[1] == "" ? index[0] : "");
    final rankLabel = args.asBlack
        ? (index[0] == "" ? index[1] : "")
        : (index[0] == "" ? index[1] : "");

    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance().then((prefs) => prefs.getString('game_mode')),
      builder: (context, snapshot) {
        Color tileColorDark;
        Color tileColorLight;

        if (snapshot.data == 'online') {
          tileColorDark = const Color(0xffcca881); // Dark color for local mode
          tileColorLight = const Color(0xffe3d0aa); // Light color for local mode

        } else {
          tileColorDark = const Color(0x9E83817F); // Dark color for online mode
          tileColorLight = const Color(0xB3F5E3CA); // Light color for online mode
        }

        return GestureDetector(
          onTapUp: (_) => logic.tapTile(index),
          child: Stack(children: [
            Positioned.fill(
              child: Container(
                color: logic.selectedTile == index
                    ? const Color(0xB36AB049) // Green color using hex value
                    : (tileColor == 'dark' ? tileColorDark : tileColorLight),
              ),
            ),
            if (logic.previousMove != null &&
                (logic.previousMove!['to'] == index ||
                    logic.previousMove!['from'] == index))
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 5.0,
                      color: logic.previousMove!['from'] == index
                          ? const Color(0xE84B8858) // Hex value for green
                          : const Color(0xFF528A52),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 2,
              left: 2,
              child: Text(rankLabel, style: labelStyle),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Text(fileLabel, style: labelStyle),
            ),
            if (logic.availableMoves.contains(index))
              Center(
                  child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.green[500],
                        shape: BoxShape.circle,
                      ))),
            if (piece != null)
              Positioned.fill(
                  child: Transform.rotate(
                      angle: args.isMultiplayer &&
                          args.asBlack ==
                              (piece!.color == chess_lib.Color.WHITE)
                          ? math.pi
                          : 0,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: PieceWidget(piece: piece!),
                      ))),
          ]),
        );
      },
    );
  }
}

// class Tile extends StatelessWidget {
//   final chess_lib.Piece? piece;
//   final String tileColor;
//   final String index;
//   Tile({super.key, required this.index})
//       : piece = logic.get(index),
//         tileColor = logic.squareColor(index)!;
//
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     var labelStyle =
//         TextStyle(color: tileColor == 'light' ? Colors.black : Colors.white);
//     final args = logic.args;
//     final fileLabel = args.asBlack
//         ? (index[1] == "" ? index[0] : "")
//         : (index[1] == "" ? index[0] : "");
//     final rankLabel = args.asBlack
//         ? (index[0] == "" ? index[1] : "")
//         : (index[0] == "" ? index[1] : "");
//     return GestureDetector(
//       onTapUp: (_) => logic.tapTile(index),
//       child: Stack(
//           children: [
//         Positioned.fill(
//           // child: FutureBuilder<SharedPreferences>(
//           //   future: SharedPreferences.getInstance(),
//           //   builder: (context, snapshot) {
//           //     if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//           //       SharedPreferences prefs = snapshot.data!;
//           //       String? gameMode = prefs.getString('game_mode');
//           //
//           //       return Container(
//           //         color: logic.selectedTile == index
//           //             ? const Color(0xB36AB049) // Green color using hex value
//           //             : (tileColor == 'dark'
//           //             ? (gameMode == 'online'
//           //             ?  const Color(0xffcca881)// DeepOrange using hex value for online mode
//           //             : const Color(0x9E83817F)) // Different color for offline mode
//           //             : (gameMode == 'online'
//           //             ? const Color(0xffe3d0aa) // gray2 using hex value for online mode
//           //             : const Color(0xB3F5E3CA))), // Different color for offline mode
//           //       );
//           //     } else {
//           //       // Return a placeholder or loading indicator while fetching SharedPreferences
//           //       return Container(
//           //         color: Colors.transparent,
//           //             // color: logic.selectedTile == index
//           //             //     ? const Color(0xB36AB049) // Green color using hex value
//           //             //     : (tileColor == 'dark' ? const Color(0x9E83817F) : const Color(0xB3F5E3CA)), // DeepOrange and gray2 using hex values
//           //           );
//           //     }
//           //   },
//           // ),
//           child: Container(
//             color: logic.selectedTile == index
//                 ? const Color(0xB36AB049) // Green color using hex value
//                 : (tileColor == 'dark' ? const Color(0x9E83817F) : const Color(0xB3F5E3CA)), // DeepOrange and gray2 using hex values
//           ),
//         ),
//         if (logic.previousMove != null
//         && (logic.previousMove!['to'] == index || logic.previousMove!['from'] == index))
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   width: 5.0,
//                   color: logic.previousMove!['from'] == index
//                       ? const Color(0xE84B8858) // Hex value for green
//                       : const Color(0xFF528A52),
//                 )
//               ),
//             ),
//           ),
//         Positioned(
//           top: 2,
//           left: 2,
//           child: Text(rankLabel, style: labelStyle),
//         ),
//         Positioned(
//           right: 2,
//           bottom: 2,
//           child: Text(fileLabel, style: labelStyle),
//         ),
//         if (logic.availableMoves.contains(index))
//           Center(
//               child: Container(
//                   width: 20, height: 20,
//                   decoration: BoxDecoration(
//                     color: Colors.green[500],
//                     shape: BoxShape.circle,
//                   ))),
//         if (piece != null)
//           Positioned.fill(
//               child: Transform.rotate(
//                   angle: args.isMultiplayer &&
//                           args.asBlack ==
//                               (piece!.color == chess_lib.Color.WHITE)
//                       ? math.pi
//                       : 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(2.0),
//                     child: PieceWidget(piece: piece!),
//                   ))),
//       ]),
//     );
//   }
// }
