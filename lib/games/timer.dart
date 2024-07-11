
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_logic.dart';

class TimerOptionPage extends StatefulWidget {
  final int? initialTime; // Accept initial time as an argument

  const TimerOptionPage({Key? key, this.initialTime}) : super(key: key);

  @override
  _TimerOptionPageState createState() => _TimerOptionPageState();
}

class _TimerOptionPageState extends State<TimerOptionPage> {
  late int selectedTime;
  String? _selectedOption = 'Option 2';
  bool _isOpen = true;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime ?? 1; // Set initial time from widget argument or default to 1
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        title: const Text('Time Duration', style: TextStyle(color: Colors.white)),
        backgroundColor: color.navy1,
        leading: const ArrowBackButton(color: Colors.white),
      ),
      body: Center(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [color.navy, Colors.black],
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RadioListTile(
                value: 'Option 2',
                groupValue: _selectedOption,
                onChanged: (value) {
                  AudioHelper.buttonClickSound();
                  setState(() {
                    _selectedOption = value as String?;
                    _isOpen = true;
                  });
                },
                title: Text(
                  'Normal Mode',
                  style: TextStyle(color: color.gray3, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              RadioListTile(
                value: 'Option 1',
                groupValue: _selectedOption,
                onChanged: (value) {
                  AudioHelper.buttonClickSound();
                  setState(() {
                    _selectedOption = value as String?;
                    _isOpen = true;
                  });
                },
                title: Text(
                  'Timer Mode',
                  style: TextStyle(color: color.gray3, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              SizedBox(height: screenHeight / 10),
              if (_selectedOption == 'Option 1' && _isOpen)
                Container(
                  height: screenHeight / 3,
                  width: screenWidth / 1.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: screenHeight / 30, left: screenWidth / 30),
                          child: Text(
                            'Timer',
                            style: GoogleFonts.oswald(
                                color: color.gray3, fontSize: screenHeight / 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Text(
                        '$selectedTime :00 Minutes',
                        style: GoogleFonts.oswald(
                            color: color.gray3, fontSize: screenHeight / 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight / 50),
                      Slider(
                        value: selectedTime.toDouble(),
                        min: 1,
                        max: 60,
                        inactiveColor: color.gray3,
                        activeColor: Colors.purple,
                        divisions: 59,
                        onChanged: (value) {
                          setState(() {
                            selectedTime = value.toInt();
                            logic.updateTimers(Duration(minutes: selectedTime));
                          });
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: screenWidth / 40, left: screenWidth / 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0',
                              style: GoogleFonts.oswald(
                                  color: color.gray3, fontSize: screenHeight / 25, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '60',
                              style: GoogleFonts.oswald(
                                  color: color.gray3, fontSize: screenHeight / 25, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: screenHeight / 10),
              Container(
                alignment: Alignment.bottomCenter,
                height: screenHeight / 20,
                width: screenWidth / 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: color.gray3,
                ),
                child: MaterialButton(
                  onPressed: () {
                    AudioHelper.buttonClickSound();
                    Navigator.pop(context, selectedTime); // Pass selected time back when popping
                    if (_selectedOption == 'Option 1') {
                      logic.args.isMultiplayer = true;
                      Navigator.pushNamed(
                        context,
                        '/colorOption1',
                        arguments: selectedTime,
                      );
                    } else if (_selectedOption == 'Option 2') {
                      logic.args.isMultiplayer = true;
                      Navigator.pushNamed(
                        context,
                        '/colorOption2',
                        arguments: selectedTime,
                      );
                    }
                  },
                  child: const Text('Start Game'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}