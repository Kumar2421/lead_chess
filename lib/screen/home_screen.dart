
import 'package:chess_game/screen/resume_screen.dart';
import 'package:chess_game/screen/homepage.dart';
import 'package:chess_game/screen/shop-screen.dart';
import 'package:chess_game/setting_page.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../user/current_user.dart';
import 'leaderboard.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.labelText});
  final String? labelText;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int newIndex = 0;
  Widget? _child;
  final CurrentUser _rememberCurrentUser = Get.put(CurrentUser());//

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  Future<void> _fetchUserData() async {
    await _rememberCurrentUser.getUserInfo();
    setState(() {
      _child =  const Homepage();
    });
  }
  @override
  Widget build(BuildContext context) {
            return
              GetBuilder(
                  init: CurrentUser(),
                  initState: (currentState){
                    _rememberCurrentUser.getUserInfo();
                  },
                  builder: (controller) {
                   return WillPopScope(
                     onWillPop: () async {
                     // Show an exit confirmation dialog
                      bool exit = await showDialog(
                       context: context,
                       builder: (context) => AlertDialog(
                         title: const Text('Exit App',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                         content: const Text('Are you sure you want to exit?',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                         actions: <Widget>[
                          TextButton(
                           onPressed: () {
                            Navigator.of(context).pop(false); // Dismiss the dialog and return false
                           },
                           child: const Text('No',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                         ),
                         TextButton(
                          onPressed: () {
                            SystemNavigator.pop(); // Minimize the app
                            //Navigator.of(context).pop(true); // Dismiss the dialog and return true
                          },
                          child: const Text('Yes',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                        ),
                      ],
                    ),
                  ); // If the user confirms exit, return true to exit the app
                      return exit ?? false;
                      },
                        child: ColorfulSafeArea(
                          color: Colors.black,
                          child: Scaffold(
                            backgroundColor:color.navy1,
                            extendBody: true,
                            body: _child ?? const CircularProgressIndicator(),
                            bottomNavigationBar: FluidNavBar(
                              icons: [
                                FluidNavBarIcon(
                                // svgPath: "assets/arrow-back.png",
                                 icon: Icons.home,
                                //  backgroundColor: Color(0xFF4285F4),
                                 extras: {"label": "Home"},
                                 ),
                                FluidNavBarIcon(
                                   // icon: Icons.zoom_in,
                                 icon: Icons.play_arrow_rounded,
                                  // backgroundColor:Color(0xFF4285F4),
                                 extras: {"label": "resume"}),
                                FluidNavBarIcon(
                                  // icon: Icons.zoom_in,
                                    icon: Icons.emoji_events,
                                    // backgroundColor:Color(0xFF4285F4),
                                    extras: {"label": "Leaderboard"}),
                                FluidNavBarIcon(
                                // icon: Icons.zoom_in,
                                  icon: Icons.shopping_cart,
                                  // backgroundColor:Color(0xFF4285F4),
                                  extras: {"label": "Shop"}),
                              ],
                              onChange: _handleNavigationChange,
                              style: const FluidNavBarStyle(
                                iconUnselectedForegroundColor: Colors.white,
                                iconSelectedForegroundColor: Colors.orangeAccent,
                                barBackgroundColor: color.navy1
                              ),
                              animationFactor: 1,
                              scaleFactor: 1.5,
                              defaultIndex: 0,
                              itemBuilder: (icon, item) => Semantics(label: icon.extras!["label"],
                                child: item,
                    ),
                  ),
              ),
            )
            );
                  },
              );
  }
  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child =  const Homepage();
          break;
        case 1:
          _child =  const ResumeScreen();
          break;
        case 2:
          _child =  const LeaderboardScreen();
          break;
        case 3:
          _child =  const Shop();
          break;
      }
    });
  }
}
