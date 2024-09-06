import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;

// class PieceWidget extends StatelessWidget {
//   final String shortName;
//   PieceWidget({super.key, required chess_lib.Piece piece}) :
//     shortName=piece.type.toString() + piece.color.toString()[6].toLowerCase();
//
//   // const PieceWidget.fromShortName({super.key, required this.shortName});
//   // static Map<String, Image> cache = {};
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final double imageHeight = screenHeight / 50;
//     final double imageWidth = screenWidth / 20;
//     return Image.asset(
//       "assets/images/pieces/classic/$shortName.png",
//        // height: imageHeight,
//        // width: imageWidth,
//       fit: BoxFit.contain,
//       errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
//         print("Error loading image: $error");
//         return const Text('Error loading image');
//       },
//     );
//   }
// }


class PieceWidget extends StatelessWidget {
  final String shortName;
  final bool useCustomImage;
  PieceWidget({super.key, required chess_lib.Piece piece, this.useCustomImage = false})
      : shortName = piece.type.toString() + piece.color.toString()[6].toLowerCase();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double imageHeight = screenHeight / 50;
    final double imageWidth = screenWidth / 20;
    final imagePath = useCustomImage
        ? "assets/images/pieces/custom/$shortName.png"
        : "assets/images/pieces/classic/$shortName.png";
    return Image.asset(
      imagePath,
      // height: imageHeight,
      // width: imageWidth,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        print("Error loading image: $error");
        return const Text('Error loading image');
      },
    );
  }
}