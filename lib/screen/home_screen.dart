

import 'package:chess_game/screen/Event_screen.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:chess_game/screen/homepage.dart';
import 'package:chess_game/screen/shop-screen.dart';
import 'package:chess_game/screen/watch_screen.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../user/current_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.labelText}) : super(key: key);
  final String? labelText;
  static List<Widget> screens = [
    Homepage(),
   // Puzzles(),
   // Watch(),
  //  More(),
  ];
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int newIndex = 0;
  Widget? _child;
  CurrentUser _rememberCurrentUser = Get.put(CurrentUser());//

  @override
  void initState() {
    _child =  Homepage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return GetBuilder(                  //
        init: CurrentUser(),              //
        initState: (currentState){              //
          _rememberCurrentUser.getUserInfo();   //
        },
        builder: (controller) {
          // PageWrapper(
          //   child:
          return Scaffold(
            extendBody: true,
            body: _child,
            bottomNavigationBar: FluidNavBar(
              icons: [
                FluidNavBarIcon(
                  // svgPath: "assets/arrow-back.png",
                  icon: Icons.home,
                  //  backgroundColor: Color(0xFF4285F4),
                  extras: {"label": "Home"},
                ),

                FluidNavBarIcon(
                    icon: Icons.zoom_in,
                    // backgroundColor:Color(0xFF4285F4),
                    extras: {"label": "Friends"}),
                FluidNavBarIcon(
                    icon: Icons.emoji_events,
                    // backgroundColor: Color(0xFF4285F4),
                    extras: {"label": "Events"}),
                FluidNavBarIcon(
                  // svgPath: "assets/conference.svg",
                    icon: Icons.shopping_cart,
                    //backgroundColor: Color(0xFF4285F4),
                    extras: {"label": "Shop"}),
              ],
              onChange: _handleNavigationChange,
              style: FluidNavBarStyle(
                iconUnselectedForegroundColor: Colors.white,
                iconSelectedForegroundColor: Colors.orangeAccent,
                barBackgroundColor: color.navy1,
              ),
              animationFactor: 1,
              scaleFactor: 1.5,
              defaultIndex: 0,
              itemBuilder: (icon, item) =>
                  Semantics(
                    label: icon.extras!["label"],
                    child: item,
                  ),
            ),
            //  ),
          );
        });
  }
  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child =  Homepage();
          break;
        case 1:
          _child =  Watch();
          break;
        case 2:
          _child =  Event();
          break;
        case 3:
          _child =  Shop();
          break;
      }

    });
  }

}


class PageWrapper extends StatelessWidget {
  final Widget child;
  const PageWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), child: child),
    );
  }
}
