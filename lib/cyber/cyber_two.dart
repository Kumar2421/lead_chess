import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:cyber_punk_tool_kit_ui/src/containers/cyber_container_two.dart';
import 'package:chess_game/colors.dart';
class CyberTwo extends StatefulWidget {
  final String? name;
  final String? imageUrl;
  final String routeName;
  const CyberTwo ({super.key, this.name, this.imageUrl,  required this.routeName,});

  @override
  State< CyberTwo > createState() => _CyberTwoState();
}

class _CyberTwoState extends State< CyberTwo >  with TickerProviderStateMixin{

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Other initialization code...
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the AnimationController
    super.dispose();
  }
  BoxDecoration get _boxDecoration => BoxDecoration(
    color: Colors.black.withOpacity(1),
  );

  double _scaleFactor = 1.0;

  _onPressed(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    // Check if the current route is not the same as the destination page route
    if (currentRoute != widget.routeName) {
      Navigator.of(context).pushReplacementNamed(widget.routeName);
    }
    print("CLICK");
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    const padding = EdgeInsets.only(top: 15);
    const margin = EdgeInsets.symmetric(vertical: 4);
    const textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    return BouncingWidget(

        scaleFactor: _scaleFactor,
        onPressed: () => _onPressed(context),
        child:Stack(
          children: [
            CyberContainerTwo(
              width: screenWidth/5,
              height: screenHeight/9,
             colorBackgroundLineFrame: Colors.transparent,
              primaryColorBackground: Colors.transparent,
              primaryColorLineFrame:  Colors.transparent,
              secondaryColorBackground: Colors.purple,
              secondaryColorLineFrame: Colors.purple,
              //animationDurationSecs: 3,
              child: Card(
                color: Colors.transparent,
                child: SizedBox(
                  child: Padding(
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          // decoration: _boxDecoration,
                          padding: padding,
                          margin: margin,
                          child: Text( widget.name??'Play with Friend',
                            style: textStyle.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Image(image: AssetImage(widget.imageUrl??'assets/people1.png'),
              color: Colors.orangeAccent,height: screenHeight/14,width: screenWidth/10,)
          ],
        )
    );
  }
}