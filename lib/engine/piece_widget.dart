import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:chess/chess.dart' as chess_lib;

class PieceWidget extends StatelessWidget {
  final String shortName; 
  PieceWidget({super.key, required chess_lib.Piece piece}) :
    shortName=piece.type.toString() + piece.color.toString()[6].toLowerCase();

  // const PieceWidget.fromShortName({super.key, required this.shortName});
  // static Map<String, Image> cache = {};

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/pieces/classic/$shortName.png",
      // height: 15,
      // width: 15,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        print("Error loading image: $error");
        return const Text('Error loading image');
      },
    );
  }
}

