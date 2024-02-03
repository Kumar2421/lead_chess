import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';

import 'chess_board.dart';

class TimeLimitPicker extends StatelessWidget {
  final int? selectedTime;
  final Function(int?)? setTime;

  const TimeLimitPicker({super.key, this.selectedTime, this.setTime});

  final Map<int, Text> timeOptions = const <int, Text>{
    0: Text('None'),
    15: Text('15m'),
    30: Text('30m'),
    60: Text('1h'),
    90: Text('1.30h'),
    120: Text('2h')
  };

  @override
  Widget build(BuildContext context) {
    return Picker<int>(
      label: 'Time Limit',
      options: timeOptions,
      selection: selectedTime,
      setFunc: setTime,
    );
  }
}

class Picker<T> extends StatelessWidget {
  final String? label;
  final Map<T, Text>? options;
  final T? selection;
  final Function(T?)? setFunc;

  Picker({this.label, this.options, this.selection, this.setFunc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoSlidingSegmentedControl<T>(
              children: options ?? {},
              groupValue: selection,
              onValueChanged: (T? val) {
                if (setFunc != null) {
                  setFunc!(val);
                }
              },
              thumbColor: Color(0x88525050),
              backgroundColor: Color(0x20000000),
            ),
      ],
    );
  }
}


class TimerWidget extends StatelessWidget {
  final Duration timeLeft;
  final Color color;

  TimerWidget({required this.timeLeft, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 50,
        child: Center(
          child: TextRegular(_durationToString(timeLeft)),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(14),
          color: Color(0x20000000),
        ),
      ),
    );
  }

  String _durationToString(Duration duration) {
    if (duration.inHours > 0) {
      String hours = duration.inHours.toString();
      String minutes =
      duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      String seconds =
      duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    } else if (duration.inMinutes > 0) {
      String minutes = duration.inMinutes.toString();
      String seconds =
      duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    } else {
      String seconds = duration.inSeconds.toString();
      return '$seconds';
    }
  }
}

class Timers extends StatelessWidget {
  final AppModel appModel;

  Timers(this.appModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return appModel.timeLimit != 0
        ? Column(
      children: [
        Container(
          child: Row(
            children: [
              TimerWidget(
                timeLeft: appModel.player1TimeLeft,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              TimerWidget(
                timeLeft: appModel.player2TimeLeft,
                color: Colors.black,
              ),
            ],
          ),
        ),
        SizedBox(height: 14),
      ],
    )
        : Container();
  }
}
const TIMER_ACCURACY_MS = 80;

class AppModel extends ChangeNotifier {
  Timer? timer;
  int timeLimit = 0;
  bool gameOver = false;
  Duration player1TimeLeft = Duration.zero;
  Duration player2TimeLeft = Duration.zero;
  Player turn = Player.player1;

  // AppModel() {
  //   loadSharedPrefs();
  // }

  void newGame(BuildContext context, {bool notify = true}) {
    // ... existing code ...

    timer = Timer.periodic(Duration(milliseconds: TIMER_ACCURACY_MS), (timer) {
      turn == Player.player1
          ? decrementPlayer1Timer()
          : decrementPlayer2Timer();
      if ((player1TimeLeft == Duration.zero ||
          player2TimeLeft == Duration.zero) &&
          timeLimit != 0) {
        endGame();
      }
    });
    if (notify) {
      notifyListeners();
    }
  }

  void exitChessView() {
    timer?.cancel();
    notifyListeners();
  }

  void decrementPlayer1Timer() {
    if (player1TimeLeft.inMilliseconds > 0 && !gameOver) {
      player1TimeLeft = Duration(
          milliseconds: player1TimeLeft.inMilliseconds - TIMER_ACCURACY_MS);
      notifyListeners();
    }
  }

  void decrementPlayer2Timer() {
    if (player2TimeLeft.inMilliseconds > 0 && !gameOver) {
      player2TimeLeft = Duration(
          milliseconds: player2TimeLeft.inMilliseconds - TIMER_ACCURACY_MS);
      notifyListeners();
    }
  }

  void endGame() {
    gameOver = true;
    timer?.cancel();
    notifyListeners();
  }

  void undoEndGame() {
    gameOver = false;
    notifyListeners();
  }

// ... existing code ...
}

class TextRegular extends StatelessWidget {
  final String text;

  TextRegular(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 24));
  }
}
class DoubleTimer extends StatefulWidget {
  const DoubleTimer({super.key});

  @override
  _DoubleTimerState createState() => _DoubleTimerState();
}

class _DoubleTimerState extends State<DoubleTimer> {
  int timeToGoA = 50000;
  int timeToGoB = 50000;

  int state = 0; //0: waiting, 1: counting A, 2: counting B

  late DateTime timeStamp;

  _DoubleTimerState() {
    print("init");
  }

  @override
  Widget build(BuildContext context) {
    print(
        "${DateTime.now().compareTo(DateTime.now().add(Duration(seconds: 1)))}");
    return Row(
      children: <Widget>[
        if (state == 1)
          ToTime(timeStamp.add(Duration(milliseconds: timeToGoA))),
        MaterialButton(
          onPressed: () {
            setState(() {
              switch (state) {
                case 0:
                  state = 1;
                  timeStamp = DateTime.now();
                  print("Running A");
                  break;
                case 1:
                  state = -1;
                  timeToGoA -=
                      DateTime.now().difference(timeStamp).inMilliseconds;
                  timeStamp = DateTime.now();
                  print("A: $timeToGoA\nRunning B");
                  break;
                case -1:
                  state = 1;
                  timeToGoB -=
                      DateTime.now().difference(timeStamp).inMilliseconds;
                  timeStamp = DateTime.now();
                  print("B: $timeToGoB\nRunning A");
                  break;
              }
            });
          },
          child: Text("switch"),
        ),
        if (state == -1)
          ToTime(timeStamp.add(Duration(milliseconds: timeToGoB))),
      ],
    );
  }
}

class ToTime extends StatelessWidget {
  final DateTime timeStamp;

  const ToTime(this.timeStamp, {super.key});

  static final Map<String, int> _times = <String, int>{
    'y': -const Duration(days: 365).inMilliseconds,
    'm': -const Duration(days: 30).inMilliseconds,
    'w': -const Duration(days: 7).inMilliseconds,
    'd': -const Duration(days: 1).inMilliseconds,
    'h': -const Duration(hours: 1).inMilliseconds,
    '\'': -const Duration(minutes: 1).inMilliseconds,
    '"': -const Duration(seconds: 1).inMilliseconds,
    "ms": -1,
  };

  Stream<String> get relativeStream async* {
    while (true) {
      int duration = DateTime.now().difference(timeStamp).inMilliseconds;
      String res = '';
      int level = 0;
      int levelSize;
      for (MapEntry<String, int> time in _times.entries) {
        int timeDelta = (duration / time.value).floor();
        if (timeDelta > 0) {
          levelSize = time.value;
          res += '$timeDelta${time.key} ';
          duration -= time.value * timeDelta;
          level++;
        }
        if (level == 2) {
          break;
        }
      }
      levelSize = _times.values.reduce(min);
      if (level > 0 && level < 2) {
        List<int> _tempList =
        _times.values.where((element) => (element < levelSize)).toList();

        if (_tempList.isNotEmpty) levelSize = _tempList.reduce(max);
      }
      if (res.isEmpty) {
        yield 'now';
      } else {
        res.substring(0, res.length - 2);
        yield res;
      }
//      print('levelsize $levelSize sleep ${levelSize - duration}ms');
      await Future.delayed(Duration(milliseconds: levelSize - duration));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: relativeStream,
        builder: (context, snapshot) {
          return Text(snapshot.data ?? '??');
        });
  }
}



//
enum Player{White, Black, player1}

class MyTimer extends ValueNotifier<int>{
  Player _turn; //White starts
  int _minutes;
  int _whiteTime;
  int _blackTime;

  MyTimer(int time) :
        _minutes = time * 60,
        _whiteTime = time * 60,
        _blackTime = time * 60,
        _turn = Player.White, //White starts
        super(time * 60 * 2);

  bool get _isWhiteTurn => Player.White == _turn;

  String get timeLeft{
    if(value != 0){
      //int time = _isWhiteTurn ? _whiteTime : _blackTime; //use this instead of playerTime if you want to display the time in seconds
      Duration left = Duration(seconds: _isWhiteTurn ? _whiteTime : _blackTime);
      String playerTime = left.toString();
      playerTime = playerTime.substring(0, playerTime.lastIndexOf('.'));
      return '${describeEnum(_turn)} turn time left : $playerTime';
    }
    else{
      return '${describeEnum(_turn)} wins!'; //We have a winner
    }
  }

  void switchPlayer() => _turn = _isWhiteTurn ? Player.Black : Player.White;
  void reset([int? time]){
    if(time != null) _minutes = time * 60; //if you want to start with a different  value
    _turn = Player.White; //White starts
    _whiteTime = _minutes; //reset time
    _blackTime = _minutes; //reset time
    value = 2*_minutes; //reset time
    //twice as long because it counts the whole time of the match (the time of the 2 players)
  }
  void start(){
    _initilizeTimer();
  }
  void _initilizeTimer(){
    Timer.periodic(
      Duration(seconds: 1),
          (Timer t) {
        if(_whiteTime == 0 || _blackTime == 0){
          t.cancel();
          switchPlayer(); //the time of one player ends, so it switch to the winner player
          value = 0; //end the game
        }
        else{
          _isWhiteTurn ? --_whiteTime : --_blackTime;
          --value;
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MyTimer clock = MyTimer(1);

  @override
  void initState(){
    super.initState();
    clock.start();
  }

  @override
  void dispose(){
    clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ValueListenableBuilder<int>(
                    valueListenable: clock,
                    builder: (context, unit, _) =>
                        Text(clock.timeLeft ,style: TextStyle(color:Colors.white, fontSize: 20, fontWeight: FontWeight.w500))
                ),
                MaterialButton(
                  child: Text('Switch',style: TextStyle(color: Colors.white),),
                  onPressed: () => clock.switchPlayer(),
                )
              ],
            ),
          );
  }
}


class ClockWidget extends StatefulWidget {
  static const routeName = "/clock";

  const ClockWidget({super.key});

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Stopwatch whiteTimer;
  late Stopwatch blackTimer;
  late Timer periodicTicker;
  bool started = false;
  bool readyToStart = false;
  bool isWhitesTurn = true;
  bool whiteFlagged = false;
  bool blackFlagged = false;
  int duration = 0;
  int whiteTimeLeft = 0;
  int blackTimeLeft = 0;

  final Color? activeColor = Colors.green[500];

  @override
  void dispose() {
    super.dispose();
  //  whiteTimer = null;
    //blackTimer = null;
    periodicTicker.cancel();
    //periodicTicker = null;
  }

  @override
  Widget build(BuildContext context) {
    // Hide notification bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return OrientationBuilder(
      builder: (context, orientation) {
        if (readyToStart == false) {
          return clockSelectionScreen();
        }

        if (orientation == Orientation.landscape) {
          return horizontalClock(context);
        }

        return verticalClock(context);
      },
    );
  }

  Widget horizontalClock(context) {
    return Center(
      child: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: (started == true
              ? MainAxisAlignment.start
              : MainAxisAlignment.center),
          mainAxisSize: MainAxisSize.max,
          children: horizontalClockTimer(
            context,
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }

  List<Widget> horizontalClockTimer(context, width, height) {
    int whiteMinutes = whiteTimeLeft >= 60 ? (whiteTimeLeft / 60).floor() : 0;
    int whiteSeconds = whiteTimeLeft - (whiteMinutes * 60);
    int blackMinutes = blackTimeLeft >= 60 ? (blackTimeLeft / 60).floor() : 0;
    int blackSeconds = blackTimeLeft - (blackMinutes * 60);

    return <Widget>[
      Container(
        width: width,
        height: height,
        child: MaterialButton(
          onPressed: handleOnWhitePressed,
          color: (isWhitesTurn == true ? activeColor : Colors.white),
          child: RotatedBox(
            quarterTurns: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (whiteFlagged == true
                  ? <Widget>[Icon(Icons.flag, color: Colors.red, size: 150)]
                  : timerButtonText(
                  "White", whiteMinutes, whiteSeconds, Colors.black)),
            ),
          ),
        ),
      ),
      Container(
        width: width,
        height: height,
        child: MaterialButton(
          onPressed: handleOnBlackPressed,
          color: (isWhitesTurn == false ? activeColor : Colors.black),
          child: RotatedBox(
            quarterTurns: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (blackFlagged == true
                  ? <Widget>[Icon(Icons.flag, color: Colors.red, size: 150)]
                  : timerButtonText(
                  "Black", blackMinutes, blackSeconds, Colors.white)),
            ),
          ),
        ),
      ),
    ];
  }

  void handleOnBlackPressed() {
    if (started) {
      setState(() {
        isWhitesTurn = false;
      });
      whiteTimer.stop();
      blackTimer.start();
    }
  }

  List<Widget> verticalClockTimer(context, width, height) {
    int whiteMinutes = whiteTimeLeft >= 60 ? (whiteTimeLeft / 60).floor() : 0;
    int whiteSeconds = whiteTimeLeft - (whiteMinutes * 60);
    int blackMinutes = blackTimeLeft >= 60 ? (blackTimeLeft / 60).floor() : 0;
    int blackSeconds = blackTimeLeft - (blackMinutes * 60);

    return <Widget>[
      Container(
        width: width,
        height: height,
        child: MaterialButton(
          onPressed: handleOnWhitePressed,
          color: (isWhitesTurn ? activeColor : Colors.white),
          child: RotatedBox(
            quarterTurns: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (whiteFlagged == true
                  ? <Widget>[Icon(Icons.flag, color: Colors.red, size: 150)]
                  : timerButtonText(
                "White",
                whiteMinutes,
                whiteSeconds,
                Colors.black,
              )),
            ),
          ),
        ),
      ),
      Container(
        width: width,
        height: height,
        child: MaterialButton(
          onPressed: handleOnBlackPressed,
          color: (isWhitesTurn == false ? activeColor : Colors.black),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (blackFlagged == true
                ? <Widget>[Icon(Icons.flag, color: Colors.red, size: 150)]
                : timerButtonText(
                "Black", blackMinutes, blackSeconds, Colors.white)),
          ),
        ),
      ),
    ];
  }

  void handleOnWhitePressed() {
    if (started == false) {
      periodicTicker = Timer.periodic(Duration(seconds: 1), (t) {
        if (whiteFlagged || blackFlagged) {
          // Game over, out of time
          t.cancel();
        }

        setState(() {
          if (whiteTimer.isRunning &&
              whiteTimer.elapsed.inSeconds <= duration) {
            whiteTimeLeft = duration - whiteTimer.elapsed.inSeconds;
          }
          if (blackTimer.isRunning &&
              blackTimer.elapsed.inSeconds <= duration) {
            blackTimeLeft = duration - blackTimer.elapsed.inSeconds;
          }
          started = true;
          whiteFlagged = whiteTimeLeft <= 0;
          blackFlagged = blackTimeLeft <= 0;
        });
      });
    }
    setState(() {
      isWhitesTurn = true;
    });
    whiteTimer.start();
    blackTimer.stop();
  }

  List<Widget> timerButtonText(String timerLabel, int minutesRemaining,
      int secondsRemaining, Color textColor) {
    String timeString = minutesRemaining.toString().padLeft(2, "0") +
        ":" +
        (secondsRemaining > 9
            ? secondsRemaining.toString().padRight(2, "0")
            : secondsRemaining.toString().padLeft(2, "0"));

    return <Widget>[
      Text(
        timerLabel,
        style: TextStyle(
          fontSize: 30,
          color: textColor,
        ),
      ),
      Text(
        timeString,
        style: TextStyle(fontSize: 75, color: textColor),
      )
    ];
  }

  Widget clockSelectionScreen() {
    return Container(
      color: Colors.grey[300],
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          timerOption("1 Hour", GameTime.Hour),
          timerOption("20 Minute", GameTime.TwentyMinute),
          timerOption("10 Minute", GameTime.TenMinute),
          timerOption("5 Minute", GameTime.FiveMinute),
          timerOption("3 Minute", GameTime.ThreeMinute),
          timerOption("1 Minute", GameTime.OneMinute),
          timerOption("30 Second", GameTime.ThirtySecond)
        ],
      ),
    );
  }

  MaterialButton timerOption(String timerText, GameTime timerOption) {
    return MaterialButton(
      onPressed: () {
        int d = 0;
        switch (timerOption) {
          case GameTime.ThirtySecond:
            d = 30;
            break;
          case GameTime.OneMinute:
            d = 60;
            break;
          case GameTime.ThreeMinute:
            d = 180;
            break;
          case GameTime.FiveMinute:
            d = 300;
            break;
          case GameTime.TenMinute:
            d = 600;
            break;
          case GameTime.TwentyMinute:
            d = 1200;
            break;
          case GameTime.Hour:
            d = 3600;
            break;
          default:
        }

        setState(() {
          duration = d;
          readyToStart = true;
          whiteTimer = new Stopwatch();
          blackTimer = new Stopwatch();
          whiteTimeLeft = d;
          blackTimeLeft = d;
        });
      },
      child: Text(
        timerText,
        style: TextStyle(
          fontSize: 30,
          backgroundColor: activeColor,
        ),
      ),
    );
  }

  Widget verticalClock(context) {
    return Center(
      child: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: (started == true
              ? MainAxisAlignment.start
              : MainAxisAlignment.center),
          mainAxisSize: MainAxisSize.max,
          children: verticalClockTimer(
            context,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height / 2,
          ),
        ),
      ),
    );
  }
}
enum GameTime {
  ThirtySecond,
  OneMinute,
  ThreeMinute,
  FiveMinute,
  TenMinute,
  TwentyMinute,
  Hour
}

class ChessTimerScreen extends StatefulWidget {
  const ChessTimerScreen({super.key});

  @override
  _ChessTimerScreenState createState() => _ChessTimerScreenState();
}

class _ChessTimerScreenState extends State<ChessTimerScreen> {
  int player1Time = 300; // 5 minutes
  int player2Time = 300; // 5 minutes
  bool isPlayer1Turn = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateTimer();
    });
  }

  void updateTimer() {
    setState(() {
      if (isPlayer1Turn) {
        if (player1Time > 0) {
          player1Time--;
        } else {
          // Player 1 ran out of time
          _timer.cancel();
        }
      } else {
        if (player2Time > 0) {
          player2Time--;
        } else {
          // Player 2 ran out of time
          _timer.cancel();
        }
      }
    });
  }

  void switchTurns() {
    setState(() {
      isPlayer1Turn = !isPlayer1Turn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chess Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPlayer1Turn ? 'Player 1\'s Turn' : 'Player 2\'s Turn',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Player 1: ${player1Time ~/ 60}:${(player1Time % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Player 2: ${player2Time ~/ 60}:${(player2Time % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                switchTurns();
              },
              child: Text('Switch Turns'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}