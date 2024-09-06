import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../buttons/back_button.dart';
import '../colors.dart';
import '../play_online.dart';

class Onlinepage extends StatelessWidget {
  const Onlinepage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.navy1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),        // Changed from ArrowBackButton to BackButton
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
                image: AssetImage('assets/home.jpeg'),
                // Ensure this image is in your assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlayOnline2()),
                    );
                  },
                  child: const Text('Play for money'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlayOnline2()),
                    );
                  },
                  child: const Text('Play for coin'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}