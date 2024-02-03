import 'package:flutter/material.dart';

class BounceButton extends StatefulWidget {
  final Widget child;
  final Function onTap;
  final double height;
  final double width;
  final Duration duration;

  const BounceButton({
    Key? key,
    required this.child,
    required this.onTap,
    required this.height,
    required this.width,
     required this.duration,
  }) : super(key: key);

  @override
  _BounceButtonState createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _controller.forward().then((_) {
          _controller.reverse();
        });
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: AnimatedContainer(
              alignment: Alignment.center,
              duration: widget.duration,
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}