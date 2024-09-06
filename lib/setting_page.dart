
import 'dart:async';

import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/colors.dart';
import 'package:chess_game/games/game_logic.dart';
import 'package:chess_game/login/emaillogin.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:chess_game/user/current_user.dart';
import 'package:chess_game/user/user_preference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:uni_links2/uni_links.dart';
import 'games/game_result_screen.dart';
import 'games/timer.dart';
import 'login/sign_in.dart';

 final logic = GetIt.instance<GameLogic>();
class User {
  final String username;
  final IconData icon;

  const User({
    required this.username,
    required this.icon,});
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  late SharedPreferences prefs;

  List<User> users=[
    const User(username: 'Rate this app', icon: Icons.star_rate),
  ];

  final AudioHelper _audioHelper = AudioHelper();
  final GameLogic _gameLogic = GetIt.instance<GameLogic>();
  @override
  void initState() {
    super.initState();
    _audioHelper.loadSoundModePreference();
   // _gameLogic.loadSoundModePreference();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  signOutUser() async {
    var resultResponse = await Get.dialog(
        AlertDialog(
          backgroundColor: Colors.grey,
          title: const Text('logout'),
          actions: [
            TextButton(onPressed: (){
              Get.back();
            },
                child: const Text("no",style: TextStyle(color: Colors.black),)),
            TextButton(onPressed: (){
              Get.back(result: 'loggedOut');
            },
                child: const Text("yes",style: TextStyle(color: Colors.black),))
          ],
        )
    );
    if (resultResponse == "loggedOut")
    {
//delete-remove the user data from phone local storage
      RememberUserPrefs.removeUserInfo()
          .then((value)
      {
        Get.off (const EmailPage());
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    const minWidth = 250.0;
    return Scaffold(
      appBar: AppBar(
       // leading: const ArrowBackButton(color: Colors.white,),
        title: const Center(child: Text('Settings',style: TextStyle(color: Colors.white),)),
        backgroundColor: color.navy1
      ),
      body:  Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: const BoxDecoration(
        image: DecorationImage(
        image: AssetImage('assets/home.jpeg'),
        fit: BoxFit.cover
        )),

        child:  SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Center(
              //   child: SwitchListTile(
              //     title: Text('Sound',style: const TextStyle(fontSize: 13,color: Colors.white)),
              //     //value:  AudioHelper.isSoundEnabled && _gameLogic.isSoundEnabled,
              //     // _audioHelper.isSoundEnabled,
              //    // _gameLogic.isSoundEnabled,
              //     onChanged: (value) {
              //       setState(() {
              //         AudioHelper.toggleSound();
              //       //  AudioHelper.toggleSound();
              //        // _gameLogic.toggleSound(); // Toggle sound mode
              //       });
              //     },
              //     secondary: Icon(Icons.volume_up, color: Colors.white),
              //   ),
              // ),
              Container(
                height: screenHeight/3.5,
                width: screenWidth/1,
                decoration: BoxDecoration(
                  // color: color.navy1.withOpacity(0.30)
                    borderRadius: BorderRadius.circular(12)
                ),
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    final user = users[index];
                    return GestureDetector(
                      child: Container(
                        height: screenHeight/14,
                        width: screenWidth/1,
                        decoration: BoxDecoration(
                          color: color.navy1.withOpacity(0.25),
                          border: const Border(
                            bottom: BorderSide(color: color.navy1, width: 1.0), // Set the border color and width for the bottom side
                          ),
                        ),
                        child: Center(
                          child: ListTile(
                            onTap: () {
                              // Navigate to the corresponding page based on the selected user
                              if (user.username == 'SignUp') {
                               // Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
                              } else if (user.username == 'Home') {
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                              } else if (user.username == 'sounds') {
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                              }
                            },
                            // textColor: color.navy1.withOpacity(0.25),
                            //  contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                            // tileColor: color.navy1.withOpacity(0.15),
                            leading:  Icon(user.icon,color: Colors.white,),
                            title: Text(user.username,style: const TextStyle(fontSize: 13,color: Colors.white),),
                            splashColor: Colors.white,
                            selectedColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              MaterialButton(
                onPressed: (){
                  signOutUser();
                },
                color: Colors.blueAccent,
                child: const Text('Logout'),
              ),
              MaterialButton(onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
              },
                child: Text("Button"),
              ),
          ],
                ),
        ),
      )
    );
  }
}


class ReferralPage extends StatefulWidget{
  const ReferralPage ({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}
class _ReferralPageState extends State<ReferralPage> {
  StreamSubscription? _sub;
  String? _referralCode;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  void _initUniLinks() async {
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleReferralLink(link);
      }
    }, onError: (err) {
      // Handle errors
    });
  }

  void _handleReferralLink(String link) {
    Uri uri = Uri.parse(link);
    if (uri.queryParameters.containsKey('code')) {
      _referralCode = uri.queryParameters['code'];
      // Navigate to the registration screen and apply the referral code
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => EmailPage(referralCode: _referralCode),
      //   ),
      // );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: Text('Referral Example'),
      ),
      body: Center(
        child: Text('Share and handle referral codes!'),
      ),
    );
  }
}



void shareReferralLink(String referralCode) {
  String referralLink = 'https://yourwebsite.com/referral?code=$referralCode';
  Share.share('Join the app using my referral link: $referralLink');
}

