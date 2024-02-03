
import 'package:chess_game/colors.dart';
import 'package:chess_game/login/phone_number_login.dart';
import 'package:chess_game/login/sign_in.dart';
import 'package:chess_game/login/sign_up.dart';
import 'package:chess_game/user/current_user.dart';
import 'package:chess_game/user/user_preference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'engine/game_logic.dart';
import 'engine/home_screen_button.dart';
import 'engine/timer.dart';

import 'package:get_it/get_it.dart';

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


  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
  List<User> users=[
    const User(username: 'SignUp',icon: Icons.person),
    const User(username: 'Home',icon: Icons.home),
    const User(username: 'sounds', icon: Icons.surround_sound_rounded),
    const User(username: 'Rate this app', icon: Icons.star_rate),
  ];
  signOutUser() async
  {
    var resultResponse = await Get.dialog(
        AlertDialog(
          backgroundColor: Colors.grey,
          title: Text('logout'),
          actions: [
            TextButton(onPressed: (){
              Get.back();
            },
                child: Text("no",style: TextStyle(color: Colors.black),)),
            TextButton(onPressed: (){
              Get.back(result: 'loggedOut');
            },
                child: Text("yes",style: TextStyle(color: Colors.black),))
          ],
        )
    );
    if (resultResponse == "loggedOut")
    {
//delete-remove the user data from phone local storage
      RememberUserPrefs.removeUserInfo()
          .then((value)
      {
        Get.off (SignIn());
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
            leading: BackButton(color: Colors.white,),
            title: Center(child: Text('Settings',style: TextStyle(color: Colors.white),)),
            backgroundColor: color.navy1
        ),
        body:  Container(
          height: screenHeight/1,
          width: screenWidth/1,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/chess1.png'),
                  fit: BoxFit.cover
              )),

          child:  SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(height: 50,),
                Container(
                  height: screenHeight/2,
                  width: screenWidth/1.1,
                  decoration: BoxDecoration(
                    // color: color.navy1.withOpacity(0.30)
                      borderRadius: BorderRadius.circular(12)
                  ),
                  // child: ListView.builder(
                  //           itemCount: friends.length,
                  //           itemBuilder: (BuildContext context, int index) {
                  //             return FriendsList(child: friends[index],);
                  //           },
                  //         ),
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = users[index];
                      return GestureDetector(
                        // onTap: () {
                        //   // Navigate to the corresponding page based on the selected user
                        //   if (user.username == 'SignUp') {
                        //     Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                        //   } else if (user.username == 'Home') {
                        //    // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                        //   }
                        //   // Add more conditions for other pages as needed
                        // },
                        child: Container(
                          height: screenHeight/14,
                          width: screenWidth/1.2,
                          decoration: BoxDecoration(
                            color: color.navy1.withOpacity(0.25),
                            border: Border(
                              bottom: BorderSide(color: color.navy1, width: 1.0), // Set the border color and width for the bottom side
                            ),
                          ),
                          child: Center(
                            child: ListTile(
                              onTap: () {
                                // Navigate to the corresponding page based on the selected user
                                if (user.username == 'SignUp') {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                                } else if (user.username == 'Home') {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                                }
                                // Add more conditions for other pages as needed
                              },
                              // textColor: color.navy1.withOpacity(0.25),
                              //  contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                              // tileColor: color.navy1.withOpacity(0.15),
                              leading:  Icon(user.icon,color: Colors.white,),
                              title: Text(user.username,style: TextStyle(fontSize: 13,color: Colors.white),),
                              splashColor: Colors.white,
                              selectedColor: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // MaterialButton(
                //   onPressed: (){
                //     Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneLoginPage()));
                //     },
                //   color: Colors.blueAccent,
                //   child: Text('phone number login'),),
                HomeScreenButton(
                    text: "Resume",
                    minWidth: minWidth,
                    onPressed: (context) {
                      Navigator.pushNamed(context, '/resume');
                    }
                ),
                //   MaterialButton(
                //     child: Text("Start Game"),
                //     color: Colors.blue,
                //     textColor: Colors.white,
                //     onPressed: () {
                //       Navigator.push(context, MaterialPageRoute(builder: (context)=>ChessTimerScreen()));
                //     },
                //   ),
                // MaterialButton(
                //   child: Text("Start Game"),
                //   color: Colors.blue,
                //   textColor: Colors.white,
                //   onPressed: () {
                //     Navigator.pushNamed(context, ClockWidget.routeName);
                //   },
                // ),
                MaterialButton(
                  onPressed: (){
                    signOutUser();
                  },
                  child: Text('Logout'),
                  color: Colors.blueAccent,

                ),
                Text(_currentUser.users.email,style: TextStyle(color: Colors.white),),
                Text(_currentUser.users.name,style: TextStyle(color: Colors.white),),
                // String sessionToken = prefs.getString('sessionToken') ?? '';
                FutureBuilder(
                  future: initPrefs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      String sessionToken = prefs.getString('sessionToken') ?? '';
                      return Text(
                        'Session Token: $sessionToken',
                        style: TextStyle(color: Colors.white),
                      );
                    } else {
                      return CircularProgressIndicator(); // You can replace this with a loading indicator.
                    }
                  },
                ),
              ],
            ),
          ),
        )
    );
  }
}