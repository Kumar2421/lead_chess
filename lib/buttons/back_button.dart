import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:chess_game/games/game_logic.dart';

import 'package:chess_game/screen/home_screen.dart';
import 'package:chess_game/screen/homepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../main.dart';
import '../server_side/websocket_manager.dart';
import '../user/current_user.dart';
import '../user/users.dart';
class ArrowBackButton extends StatefulWidget {
  final Color color;

  const ArrowBackButton({super.key, required this.color});

  @override
  _ArrowBackButtonState createState() => _ArrowBackButtonState();
}

class _ArrowBackButtonState extends State<ArrowBackButton> {
  // final List<String> websocketUrls = [
  //   'ws://93.127.206.44:3007',
  //   // Add more WebSocket server URLs as needed
  // ];
  //late List<WebSocketChannel> _channels;
  late String playerName = '';
  final CurrentUser _currentUser = Get.put(CurrentUser());
  late Users currentUser;
  late Map<String, dynamic> userData = {};
  late WebSocketManager webSocketManager;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadUserData();
    webSocketManager = GetIt.instance<WebSocketManager>();
    //initializeWebSocket();
    initializePrefs();

  }
  Future<void> initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String name = _currentUser.users.name;
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      setState(() {
        playerName = name;
        userData = jsonDecode(userDataString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          onTap: () {
            final prefs = GetIt.instance<SharedPreferences>();
            String? sessionToken = prefs.getString('sessionToken');

            final exitMessage = json.encode({
              'type': 'player_exit',
              //'username': playerName,
              'sessionToken': sessionToken,// Replace with the actual current player username
            });

            // Debug: print the message before sending
            print('Sending exit message: $exitMessage');


            webSocketManager.send(exitMessage);
            print('Sent game state update to server: $exitMessage');


            AudioHelper.buttonClickSound();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
          child: Image(
            image: const AssetImage('assets/arrow-back.png'),
            height: screenHeight / 25,
            width: screenWidth / 12,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class ArrowBackButton2 extends StatelessWidget {
  final Color color;
  const ArrowBackButton2({super.key, required this.color,});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child:    Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap:(){
              //  Navigator.push(context, MaterialPageRoute(builder: (context)=>const PlayLocal()));
            },
            child: Image(
                image: const AssetImage('assets/arrow-back.png'),height: screenHeight/20,width: screenWidth/10,color: color),
          )),
    );
  }
}


class AudioHelper {
  static final player = AudioPlayer();

  static bool isSoundEnabled = true; // Initially sound is enabled

  static void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
  }
  void loadSoundModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true; // Default is true if preference is not found
    //notifyListeners();
  }
  static Future<void> playSound(String audioPath) async {
    if (isSoundEnabled) {
      await player.play(AssetSource(audioPath));
    }
  }
  static Future<void> buttonClickSound() async {
    String audioPath = "audio/click_sound.mp3";
    await playSound(audioPath);
  }

  static Future<void> playMoveSound() async {
    String audioPath = "audio/move_time_sound.mp3";
    await playSound(audioPath);
  }

  static Future<void> playPromotionMoveSound() async {
    String audioPath = "audio/promotion_sound.mp3";
    await playSound(audioPath);
  }

  static Future<void> playPieceToPieceCaptureSound() async {
    String audioPath = "audio/piece_to_piece_capture_sound.mp3";
    await playSound(audioPath);
  }

}