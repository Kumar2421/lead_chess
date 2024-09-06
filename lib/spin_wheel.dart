import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chess_game/user/current_user.dart';
import 'package:chess_game/user/users.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kbspinningwheel/kbspinningwheel.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'colors.dart';
import 'notification_page.dart';

class Spin extends StatefulWidget {
  const Spin({super.key});

  @override
  State<Spin> createState() => _SpinState();
}

class _SpinState extends State<Spin> {
  final StreamController<int> _dividerController = StreamController<int>();
  final StreamController<double> _wheelNotifier = StreamController<double>();
  Map<String, ui.Image> _loadedImages = {};
  Users currentUser = Get.find<CurrentUser>().users;
  bool _isSpinning = false;
  bool _timerActive = false; // State to manage the timer status
  int _selected = 0; // Variable to store the selected index
  String _selectedLabel = '';

  final Map<int, String> labels = {
    1: '100',
    2: '40',
    3: '80',
    4: '700',
    5: '500',
    6: '30',
    7: '200',
    8: '10',
  };
   static  final _duration = Duration(minutes: 1);
   Duration _remainingTime = _duration;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void dispose() {
    _dividerController.close();
    _wheelNotifier.close();
  //  _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadImages() async {
    final images = await loadImages([
      'assets/Dollar.png',
      'assets/Dollar.png',
      'assets/Dollar.png',
      'assets/Dollar.png',
      'assets/Dollar.png',
      'assets/Dollar.png',
      'assets/Dollar.png',
      'assets/Dollar.png',
    ]);
    setState(() {
      _loadedImages = images;
    });
  }

  Future<void> _sendScoreToBackend(int selected) async {
    final url = Uri.parse('https://schmidivan.com/Esakki/ChessGame/spinwheel_reward');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': currentUser.userId, 'total_amount': selected}),
    );

    if (response.statusCode == 200) {
      print('Score stored successfully');
    } else {
      print('Failed to store score');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final timerService = Provider.of<TimerService>(context);
    return ColorfulSafeArea(
      color: Colors.black,
      child: Scaffold(
        body:
        Container(
          height: screenHeight,
          width: screenWidth,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/Designer.jpeg'),
                  fit: BoxFit.cover)),
          child:
          Column(
          //  mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppBar(
                  title: Text("Lucky Spin",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  backgroundColor: Colors.transparent, elevation: 0.0),
                SizedBox(height: screenHeight/5,),
                _loadedImages.isNotEmpty
                    ?
                Stack(
                     alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      ignoring: true,   // stop the manual rotating action in spinning wheel
                      child: SpinningWheel(
                        image: Container(
                          width: 310,
                          height: 310,
                          child: CustomPaint(
                            painter: CircleDividerPainter(
                              dividers: 8,
                              labels: [
                                '80', '700', '500', '30', '200', '10', '100', '40'
                              ],
                              colors: [
                                Colors.blue.withOpacity(0.5),
                                Colors.indigo.withOpacity(0.5),
                                Colors.blue.withOpacity(0.5),
                                Colors.indigo.withOpacity(0.5),
                                Colors.blue.withOpacity(0.5),
                                Colors.indigo.withOpacity(0.5),
                                Colors.blue.withOpacity(0.5),
                                Colors.indigo.withOpacity(0.5),
                              ],
                              imagePaths: [
                                'assets/Dollar.png',
                                'assets/Dollar.png',
                                'assets/Dollar.png',
                                'assets/Dollar.png',
                                'assets/Dollar.png',
                                'assets/Dollar.png',
                                'assets/Dollar.png',
                                'assets/Dollar.png',
                              ],
                              images: _loadedImages,
                              //selected: _selected,
                              selectedLabel: _selectedLabel,
                            ),
                          ),
                        ),
                        width: 310,
                        height: 310,
                        initialSpinAngle: _generateRandomAngle(),
                        spinResistance: 0.1,
                        canInteractWhileSpinning: false,
                        dividers: 8,
                        onUpdate: _dividerController.add,
                        onEnd: (int selected) {
                          _dividerController.add(selected);
                          final selectedLabel = labels[selected];
                          if (selectedLabel != null) {
                            _sendScoreToBackend(int.parse(selectedLabel));
                            setState(() {
                              _isSpinning = false;
                              _selectedLabel = selectedLabel; // Update the selected label
                            });
                          }
                          // _sendScoreToBackend(int.parse(labels[selected]!));
                          // setState(() {
                          //   _selected = selected;
                          //   _isSpinning = false;
                          // });
                        },
                        secondaryImage: Image.asset('assets/hourHand.png',color: Colors.red,),
                        secondaryImageHeight: 300,
                        secondaryImageWidth: 250,
                        shouldStartOrStop: _wheelNotifier.stream,
                      ),
                    ),
                  ],
                )
                   : CircularProgressIndicator(),

              SizedBox(height: 30),
              StreamBuilder(
                stream: _dividerController.stream,
                builder: (context, snapshot) => snapshot.hasData
                    ? RouletteScore(snapshot.data as int)
                    : Container(),
              ),
              SizedBox(height: 30),
              if (timerService.spinTimerActive)
                Text(
                  _formatDuration(timerService.spinRemainingTime),
                  style: TextStyle(fontSize: 30),
                )
              else
              ElevatedButton(
                onPressed:
                !_isSpinning && !_timerActive
                    ? () {
                  timerService.startSpinTimer(Duration(minutes: 1));
                  setState(() {
                    _isSpinning = true;
                  });
                  _wheelNotifier.sink.add(_generateRandomVelocity());
                 // _startNewTimer();
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(160, 40), // Set the desired width and height
                  backgroundColor: Colors.white.withOpacity(0.6)
                ),
                child: _timerActive
                    ? Text(_formatDuration(_remainingTime))
                    : Text("Start"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _generateRandomVelocity() => (Random().nextDouble() * 6000) + 2000;
  double _generateRandomAngle() => Random().nextDouble() * pi * 2;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}

class RouletteScore extends StatelessWidget {
  final int selected;

  final Map<int, String> labels = {
    1: '100',
    2: '40',
    3: '80',
    4: '700',
    5: '500',
    6: '30',
    7: '200',
    8: '10',
  };

  RouletteScore(this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text('${labels[selected]}',
        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 24.0));
  }
}

Future<Map<String, ui.Image>> loadImages(List<String> imagePaths) async {
  final Map<String, ui.Image> images = {};
  for (var path in imagePaths) {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo fi = await codec.getNextFrame();
    images[path] = fi.image;
  }
  return images;
}

class CircleDividerPainter extends CustomPainter {
  final int dividers;
  final List<String> labels;
  final List<Color> colors;
  final List<String> imagePaths;
  final Map<String, ui.Image> images;
  //final int selected;
  final String selectedLabel;

  CircleDividerPainter({
    required this.dividers,
    required this.labels,
    required this.colors,
    required this.imagePaths,
    required this.images,
   // required this.selected,
    required this.selectedLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.width / 2, size.height / 2);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double elevation = 3.0; // Adjust elevation as needed

    for (int i = 0; i < dividers; i++) {
      final Paint paint = Paint()
       // ..color = i == selected ? Colors.green :colors[i % colors.length]
        ..color = labels[i] == selectedLabel ? Colors.green : colors[i]
        ..style = PaintingStyle.fill;
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, elevation);
      // if (i == selected) {
      //   paint.color = Colors.green; // Change color for the selected divider
      // } else {
      //   paint.color = colors[i % colors.length]; // Use normal color from the list
      // }


      final double startAngle = (2 * pi / dividers) * i;
      final double sweepAngle = (2 * pi / dividers);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final Paint linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0;

      final double dx = center.dx + radius * cos(startAngle);
      final double dy = center.dy + radius * sin(startAngle);
      canvas.drawLine(center, Offset(dx, dy), linePaint);

      final imageAngle = startAngle + sweepAngle / 2;
      final imageDx = center.dx + (radius / 2) * cos(imageAngle);
      final imageDy = center.dy + (radius / 2) * sin(imageAngle);
      final ui.Image image = images[imagePaths[i]]!;

      final double imageWidth = radius / 6;
      final double imageHeight = radius / 6;
      final double imageX = imageDx - imageWidth / 2;
      final double imageY = imageDy - imageHeight / 2;

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(imageX, imageY, imageWidth, imageHeight),
        Paint(),
      );

      // Draw the text label
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final double textAngle = startAngle + sweepAngle / 2;
      final double textDx = center.dx + (radius / 1.5) * cos(textAngle);
      final double textDy = center.dy + (radius / 1.5) * sin(textAngle);

      // Save the canvas state before rotating it
      canvas.save();

      // Rotate the canvas to ensure the text is upright
      canvas.translate(textDx, textDy);
      canvas.rotate(textAngle + pi / 2);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);

      // Draw the text
      textPainter.paint(canvas, Offset(0, 0));

      // Restore the canvas state
      canvas.restore();
    }

    final borderPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(CircleDividerPainter oldDelegate) {
    return false;
  }
}



class TimerService with ChangeNotifier {
  Timer? _rewardDialogTimer;
  Timer? _spinTimer;
  Timer? _offlineTimer;
  DateTime? _rewardDialogStartTime;
  DateTime? _spinStartTime;
  DateTime? _offlineStartTime;
  Duration _rewardDialogRemainingTime = Duration.zero;
  Duration _spinRemainingTime = Duration.zero;
  Duration _offlineRemainingTime = Duration.zero;
  bool _rewardDialogTimerActive = false;
  bool _spinTimerActive = false;
  bool _offlineTimerActive = false;

  Duration get rewardDialogRemainingTime => _rewardDialogRemainingTime;
  Duration get spinRemainingTime => _spinRemainingTime;
  Duration get offlineRemainingTime => _offlineRemainingTime;
  bool get rewardDialogTimerActive => _rewardDialogTimerActive;
  bool get spinTimerActive => _spinTimerActive;
  bool get offlineTimerActive => _offlineTimerActive;

  void startRewardDialogTimer(Duration duration) {
    _rewardDialogStartTime = DateTime.now();
    _rewardDialogRemainingTime = duration;
    _rewardDialogTimerActive = true;
    _rewardDialogTimer?.cancel();
    _rewardDialogTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final remaining = duration - Duration(seconds: timer.tick);
      if (remaining <= Duration.zero) {
        timer.cancel();
        _rewardDialogTimerActive = false;
        _rewardDialogRemainingTime = Duration.zero;
        NotificationService.showNotification(
          title: 'free coin Timer Complete',
          body: 'Your free coin timer has completed!',
          payload: {'navigate': 'true'}, // Example payload
          actionType: ActionType.Default,
          notificationLayout: NotificationLayout.Default,
          category: null, // Optional category
          bigPicture: null, // Optional big picture
          actionButtons: null, // Optional action buttons
          scheduled: false, // Set to true if scheduling
          interval: null, // Interval if scheduled
        );
        notifyListeners();
      } else {
        _rewardDialogRemainingTime = remaining;
      }
      notifyListeners();
    });
  }

  void startOfflineTimer(Duration duration) {
    _offlineStartTime = DateTime.now();
    _offlineRemainingTime = duration;
    _offlineTimerActive = true;
    _offlineTimer?.cancel();
    _offlineTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final remaining = duration - Duration(seconds: timer.tick);
      if (remaining <= Duration.zero) {
        timer.cancel();
        _offlineTimerActive = false;
        _offlineRemainingTime = Duration.zero;
        notifyListeners();
      } else {
        _offlineRemainingTime = remaining;
      }
      notifyListeners();
    });
  }

  void startSpinTimer(Duration duration) {
    _spinStartTime = DateTime.now();
    _spinRemainingTime = duration;
    _spinTimerActive = true;
    _spinTimer?.cancel();
    _spinTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final remaining = duration - Duration(seconds: timer.tick);
      if (remaining <= Duration.zero) {
        timer.cancel();
        _spinTimerActive = false;
        _spinRemainingTime = Duration.zero;
        NotificationService.showNotification(
          title: 'Spin Timer Complete',
          body: 'Your spin timer has completed!',
          payload: {'navigate': 'true'}, // Example payload
          actionType: ActionType.Default,
          notificationLayout: NotificationLayout.Default,
          category: null, // Optional category
          bigPicture: null, // Optional big picture
          actionButtons: null, // Optional action buttons
          scheduled: false, // Set to true if scheduling
          interval: null, // Interval if scheduled
        );
        notifyListeners();
      } else {
        _spinRemainingTime = remaining;
      }
      notifyListeners();
    });
  }

  void cancelRewardDialogTimer() {
    _rewardDialogTimer?.cancel();
    _rewardDialogTimerActive = false;
    _rewardDialogRemainingTime = Duration.zero;
    notifyListeners();
  }

  void cancelSpinTimer() {
    _spinTimer?.cancel();
    _spinTimerActive = false;
    _spinRemainingTime = Duration.zero;
    notifyListeners();
  }
}