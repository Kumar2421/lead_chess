import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chess_game/colors.dart';
import 'color_option2.dart';
import 'coloroption3.dart';
import 'game_logic.dart';
import '';
// Assuming `color` and other imports are correctly included.
// import 'path_to_your_color_class.dart'; // Update this with the correct path.

final logic = GetIt.instance<GameLogic>();

class SkillsOption3 extends StatefulWidget {
  const SkillsOption3({super.key});

  @override
  _SkillsOption3State createState() => _SkillsOption3State();
}

class _SkillsOption3State extends State<SkillsOption3> {
  @override
  void initState() {
    super.initState();
    _setDifficultyAndNavigate();
  }

  Future<void> _setDifficultyAndNavigate() async {
    // Set the difficulty to "Normal"
    logic.args.difficultyOfAI = "Normal";

    // Show loading screen for 3 seconds
    await Future.delayed(const Duration(seconds: 1));
    logic.args.isMultiplayer = false;
    // Navigate to the next screen
    Navigator.push(context, MaterialPageRoute(builder: (context) =>const ColorOption3()));
    //Navigator.pushNamed(context, '/colorOption3');

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