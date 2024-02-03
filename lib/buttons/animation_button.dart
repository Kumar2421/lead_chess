import 'package:button_animations/button_animations.dart';
import 'package:chess_game/colors.dart';
import 'package:flutter/material.dart';

class AnimationButton extends StatefulWidget {
  final Widget child;
  final Function onTap;
  final double height;
  final double width;
  final double blurRadius;
  final Color color,shadowColor;
  const AnimationButton({ Key? key,
    required this.child,
    required this.onTap,
    required this.width,
    required this.height,
    required this.color, required this.shadowColor, required this.blurRadius,
  }) : super(key: key);

  @override
  State<AnimationButton> createState() => _AnimationButtonState();
}

class _AnimationButtonState extends State<AnimationButton> {
  @override
  Widget build(BuildContext context) {
    return  AnimatedButton(
      type: null,
      blurRadius: widget.blurRadius,
      shadowColor: widget.shadowColor,
      //color.blue3,
      color: widget.color,
      //color.navy,
      //borderColor: color.navy,
      // blurColor: color.beige2,
      height: widget.height,
      width: widget.width,
      onTap: () {
        widget.onTap();
      },
      child: widget.child
      // Text('Create Tournament', // add your text here
      //   style: TextStyle(
      //       color: Colors.white,fontWeight: FontWeight.bold
      //   ),
      // ),
    );
  }
}
