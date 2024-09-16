import 'dart:io' show Platform;
import 'dart:math';
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'LocalGamepage3.dart';
import 'package:get_it/get_it.dart';
import 'game_logic.dart';
<<<<<<< HEAD
=======
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> d93d3c4 (Initial commit)

final logic = GetIt.instance<GameLogic>();
const String testDevice = 'YOUR_DEVICE_ID';

class ColorOption3 extends StatefulWidget {
  const ColorOption3({super.key});

  @override
  State<ColorOption3> createState() => _ColorOption3State();
}

class _ColorOption3State extends State<ColorOption3> {
  @override
  void initState() {
    super.initState();
    MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [testDevice]));
    _startGameWithRandomColor(); // Start the game immediately on load
  }

  void _startGameWithRandomColor() {
    setState(() {
      // Show loading screen immediately
    });
<<<<<<< HEAD

    // Simulate some delay (e.g., network request) before starting the game
    Future.delayed(const Duration(seconds: 1), () {
=======
// Import SharedPreferences package

// Simulate some delay (e.g., network request) before starting the game
    Future.delayed(const Duration(seconds: 1), () async {
>>>>>>> d93d3c4 (Initial commit)
      final random = Random();
      final isBlack = random.nextBool(); // Randomly selects true (Black) or false (White)

      logic.args.asBlack = isBlack;
      AudioHelper.buttonClickSound();
<<<<<<< HEAD
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LocalGamepage3(selectedTime: 20,),
        ),
      );
=======

      // Store the player's and opponent's color in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String playerColor;
      String opponentColor;

      // Set and print the player's color based on the random selection
      if (isBlack) {
        playerColor = 'black';
        opponentColor = 'white';
      } else {
        playerColor = 'white';
        opponentColor = 'black';
      }

      await prefs.setString('selected_color', playerColor);
      await prefs.setString('opponent_color', opponentColor);

      // Print the colors
      print('Player color: $playerColor');
      print('Opponent color: $opponentColor');

      // Proceed to start the game and navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LocalGamepage3(selectedTime: 20),
        ),
      );

>>>>>>> d93d3c4 (Initial commit)
      logic.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.navy1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: Padding(
          padding: EdgeInsets.only(right: screenWidth / 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'PLAY ',
                    style: GoogleFonts.oswald(
                      color: Colors.white,
                      fontSize: screenWidth / 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ONLINE',
                    style: GoogleFonts.oswald(
                      fontSize: screenWidth / 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: screenHeight / 400,
                  width: screenWidth / 5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.amber, Colors.white],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/home.jpeg'), // Set your loading background image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
