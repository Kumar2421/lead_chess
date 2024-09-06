
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/colors.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'game_logic.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class TimerOptionPage extends StatefulWidget {
  final int? initialTime; // Accept initial time as an argument

  const TimerOptionPage({super.key, this.initialTime});

  @override
  _TimerOptionPageState createState() => _TimerOptionPageState();
}

class _TimerOptionPageState extends State<TimerOptionPage> {
  late int selectedTime;
  String? _selectedOption = 'Option 2';
  bool _isOpen = true;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime ?? 1; // Set initial time from widget argument or default to 1
  }

  late final _intervalsWheel = WheelPickerController(
    itemCount: intervals.length,
    initialIndex: intervals.indexOf(Duration(minutes: 1)), // Initial selected index
  );


  Duration selectedInterval = intervals[0];

  static const intervals = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 20),
    Duration(minutes: 30),
    Duration(minutes: 40),
    Duration(minutes: 50),
    Duration(hours: 1),
  ];


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    const textStyle = TextStyle(
        fontSize: 30.0, height: 1.8,color: Colors.white);
    final selectedTextStyle = textStyle.copyWith(color: Colors.blue); // Change this to your preferred selected color
    final unselectedTextStyle = textStyle.copyWith(color: Colors.black); // Change this to your preferred unselected color

    final wheelStyle = WheelPickerStyle(
      size: 400,
      itemExtent: textStyle.fontSize! * textStyle.height!,
      // Text height
      squeeze: 1.25,
     // diameterRatio: .8,
      //surroundingOpacity: .25,
      magnification: 1.2,
    );

    Widget itemBuilder(BuildContext context, int index) {
      final interval = intervals[index];
      return Text(_formatDuration(interval), style: textStyle);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        title: const Text('Time Duration', style: TextStyle(color: Colors.white)),
        backgroundColor: color.navy1,
        leading: ArrowBackButton(color: Colors.white),
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
              SizedBox(height: screenHeight/25,),
              // ClipPath(
              //     clipper: ParallelogramClipper(),
              // child: Container(
              //   height: screenHeight/15,
              //   width: screenWidth/1.8,
              //   color: Colors.white,
              //   child:
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
           //   ),),
             SizedBox(height: screenHeight/50,),
              // ClipPath(
              //     clipper: ParallelogramClipper(),
              // child: Container(
              //   height: screenHeight/15,
              //   width: screenWidth/1.8,
              //   color: Colors.white,
              //   child:
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
           //   )),
              SizedBox(height: screenHeight / 20),
              if (_selectedOption == 'Option 1' && _isOpen)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(
                    //   width: screenWidth,
                    //   height: 300,
                    //   child: CupertinoPicker(
                    //     backgroundColor: color.navy1,
                    //     itemExtent: textStyle.fontSize! * textStyle.height!,
                    //     onSelectedItemChanged: (index) {
                    //       setState(() {
                    //         selectedIndex = index;
                    //         selectedInterval = intervals[index];
                    //         selectedTime = selectedInterval.inMinutes;
                    //       });
                    //     },
                    //     children: List<Widget>.generate(intervals.length, (index) {
                    //       final interval = intervals[index];
                    //       return Container(
                    //         color: selectedIndex == index ? Colors.yellow[300] : Colors.white,
                    //         child: Center(
                    //           child: Text(
                    //             _formatDuration(interval),
                    //             style: selectedIndex == index ? selectedTextStyle : unselectedTextStyle,
                    //           ),
                    //         ),
                    //       );
                    //     }),
                    //   ),
                    // ),
                    Container(
                      color: Colors.transparent,
                     //    decoration: const BoxDecoration(
                     //      gradient: LinearGradient(
                     //        colors: [color.navy, Colors.black],
                     //        begin: Alignment.topRight,
                     //        end: Alignment.bottomRight,
                     //      ),
                     //    ),
                        width: wheelStyle.size,
                        height: wheelStyle.itemExtent * 5,
                        child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _centerBar(context),
                              WheelPicker(
                                builder: itemBuilder,
                                controller: _intervalsWheel,
                                looping: false,
                                style: wheelStyle,
                                //           .copyWith(
                                //     shiftAnimationStyle: const WheelShiftAnimationStyle(
                                //     duration: Duration(seconds: 1),
                                //     curve: Curves.bounceOut,
                                //   ),
                                // ),
                                selectedIndexColor:  Color(0xE040F9FF),
                                onIndexChanged: (index) {
                                        setState(() {
                                          selectedIndex = index;
                                          selectedInterval = intervals[index];
                                          selectedTime = selectedInterval.inMinutes;
                                        });
                                      },
                              ),
                            ]
                        )
                    ),
                  ],
                ),
                // Container(
                //   height: screenHeight / 3,
                //   width: screenWidth / 1.1,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //     color: Colors.white.withOpacity(0.1),
                //   ),
                //   child: Column(
                //     children: [
                //       Align(
                //         alignment: Alignment.topLeft,
                //         child: Padding(
                //           padding: EdgeInsets.only(top: screenHeight / 30, left: screenWidth / 30),
                //           child: Text(
                //             'Timer',
                //             style: GoogleFonts.oswald(
                //                 color: color.gray3, fontSize: screenHeight / 25, fontWeight: FontWeight.bold),
                //           ),
                //         ),
                //       ),
                //       Text(
                //         '$selectedTime :00 Minutes',
                //         style: GoogleFonts.oswald(
                //             color: color.gray3, fontSize: screenHeight / 25, fontWeight: FontWeight.bold),
                //       ),
                //       SizedBox(height: screenHeight / 50),
                //       Slider(
                //         value: selectedTime.toDouble(),
                //         min: 1,
                //         max: 60,
                //         inactiveColor: color.gray3,
                //         activeColor: Colors.purple,
                //         divisions: 59,
                //         label:  '${selectedTime.toInt()} min',
                //         onChanged: (value) {
                //           setState(() {
                //             selectedTime = value.toInt();
                //             print('Updated selectedTime: $selectedTime'); // Debug print to verify change
                //             logic.updateTimers(Duration(minutes: selectedTime));
                //           });
                //         },
                //       ),
                //       Padding(
                //         padding: EdgeInsets.only(right: screenWidth / 40, left: screenWidth / 40),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text(
                //               '0',
                //               style: GoogleFonts.oswald(
                //                   color: color.gray3, fontSize: screenHeight / 25, fontWeight: FontWeight.bold),
                //             ),
                //             Text(
                //               '60',
                //               style: GoogleFonts.oswald(
                //                   color: color.gray3, fontSize: screenHeight / 25, fontWeight: FontWeight.bold),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              SizedBox(height: screenHeight / 10),
              Container(
                alignment: Alignment.bottomCenter,
                height: screenHeight / 20,
                width: screenWidth / 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: MaterialButton(
                  onPressed: () {
                   // AudioHelper.buttonClickSound();
                    print('Navigating to /localGame1 with selectedTime: $selectedTime'); // Debug print
                    Navigator.pop(context, selectedTime); // Pass selected time back when popping
                    if (_selectedOption == 'Option 1') {
                      // logic.args.isMultiplayer = true;
                      Navigator.pushNamed(
                        context,
                        '/colorOption1',
                        arguments: selectedTime,
                      );
                    } else if (_selectedOption == 'Option 2') {
                     // logic.args.isMultiplayer = true;
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
  @override
  void dispose() {
    //_intervalsWheel.dispose();
    // _selectedIndex.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes';
    } else {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    }
  }

  Widget _centerBar(BuildContext context) {
    return Center(
      child: Container(
        height: 40.0,
        decoration: BoxDecoration(
          color: Colors.grey,
          //color: const Color(0xFF0F24CE).withAlpha(26),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
  String _getUnitLabel(Duration duration) {
    return duration.inHours > 0 ? 'hours' : 'minutes';
  }
}



class ParallelogramClipper extends CustomClipper<Path> {
  final double borderSize;
  final Color borderColor;

  ParallelogramClipper({this.borderSize = 5.0, this.borderColor = color.blue3});

  @override
  Path getClip(Size size) {
    // Path path = Path();
    // path.moveTo(size.width * 0.1, 0); // Move to top left with an offset
    // path.lineTo(size.width, 0); // Line to top right
    // path.lineTo(size.width * 0.9, size.height); // Line to bottom right with an offset
    // path.lineTo(0, size.height); // Line to bottom left
    // path.close(); // Close the path
    // return path;

    final height = size.height;
    final width = size.width;


    // Path path = Path();
    // path.moveTo(width * 0.5, 0);
    // path.lineTo(width, height * 0.25);
    // path.lineTo(width, height * 0.75);
    // path.lineTo(width * 0.5, height);
    // path.lineTo(0, height * 0.75);
    // path.lineTo(0, height * 0.25);
    // path.close();

    // Path path = Path();
    // path.lineTo(0, height);
    // path.lineTo(width * 0.9, height);
    // path.lineTo(width, 0);
    // path.close();

    Path path = Path();
    path.lineTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width * 0.9, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}



class WheelChooserExample extends StatefulWidget {
  const WheelChooserExample({super.key});

  @override
  State<WheelChooserExample> createState() => _WheelChooserExampleState();
}

class _WheelChooserExampleState extends State<WheelChooserExample> {
  int selectedIntervalIndex = 0;

  static const intervals = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 20),
    Duration(minutes: 30),
    Duration(minutes: 40),
    Duration(minutes: 50),
    Duration(hours: 1),
  ];

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 26.0, height: 1.5);

    return Scaffold(
      appBar: AppBar(
        title: Text('Time Picker Example'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 200,
                child: WheelChooser(
                  onValueChanged: (index) {
                    setState(() {
                      selectedIntervalIndex = index;
                    });
                  },
                  datas: intervals.map((interval) => _formatDuration(interval)).toList(),
                  selectTextStyle: textStyle,
                  unSelectTextStyle: textStyle.copyWith(color: Colors.grey),
                  startPosition: intervals.indexOf(Duration(minutes: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes';
    } else {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    }
  }
}