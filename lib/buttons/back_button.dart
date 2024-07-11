import 'package:audioplayers/audioplayers.dart';
import 'package:chess_game/games/game_logic.dart';

import 'package:chess_game/screen/home_screen.dart';
import 'package:chess_game/screen/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ArrowBackButton extends StatelessWidget {
  final Color color;
  const ArrowBackButton({super.key, required this.color,});

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
              AudioHelper.buttonClickSound();
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
            },
            child: Image(
              image: const AssetImage('assets/arrow-back.png'),height: screenHeight/25,width: screenWidth/12,color: color),
          )),
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
//   static Future<void> buttonClickSound() async {
//     String audioPath = "audio/click_sound.mp3";
//     final player = AudioPlayer();
//     await player.play(AssetSource((audioPath)));
   
//   }
//   static Future<void>  playMoveSound() async {
   
//       String audioPath = "audio/move_time_sound.mp3";
//       await player.play(AssetSource((audioPath)));
    
//   }
//  static Future<void>  playPromotionMoveSound() async {
  
//      String audioPath = "audio/promotion_sound.mp3";
//      await player.play(AssetSource((audioPath)));
 
//   }

//  static Future<void> playPieceToPieceCaptureSound() async {
//   //  AudioHelper audioHelper = AudioHelper();
//   //  audioHelper.loadSoundModePreference();
//   //  if (audioHelper.isSoundEnabled) {
//      String audioPath = "audio/piece_to_piece_capture_sound.mp3";
//      await player.play(AssetSource((audioPath)));
//   // }
//   }
}