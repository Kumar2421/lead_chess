
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/buttons/bounce_button.dart';
import 'package:chess_game/colors.dart';
import 'package:chess_game/games/board_piece.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wakelock/wakelock.dart';
import '../screen/homepage.dart';
import 'piece_widget.dart';
import 'package:flutter/material.dart';
import 'player_bar.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:io';
import 'package:get_it/get_it.dart';
import 'game_logic.dart';
final logic = GetIt.instance<GameLogic>();
const String testDevice = 'YOUR_DEVICE_ID';
const int maxFailedLoadAttempts = 3;
class LocalGame1 extends StatefulWidget {
  final int selectedTime;

  const LocalGame1({super.key, required this.selectedTime});

  @override
  State<LocalGame1> createState() => _LocalGame1State();
}

class _LocalGame1State extends State<LocalGame1> {
  void update() => setState(() => {});
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  final double _scaleFactor = 1.0;
  // late int selectedTime;

  @override
  void initState() {
    logic.addListener(update);
    super.initState();
    // MobileAds.instance.updateRequestConfiguration(
    //     RequestConfiguration(testDeviceIds: [testDevice]));
    // _createInterstitialAd();
    // _loadBannerAd();
    print('LocalGame1 selectedTime on initState: ${widget.selectedTime}'); // Debug print
    // logic.updateTimers(Duration(minutes: widget.selectedTime));
     //logic.updateTimers(Duration(minutes: widget.selectedTime ?? 5));
    Wakelock.enable();
  }
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId:  Platform.isAndroid
            ? 'ca-app-pub-6174775436583072/1262806049'
        //'ca-app-pub-7319269804560504/6941421099'
            : 'ca-app-pub-7319269804560504/3520838807',
        //getInterstitialAdUnitId()!,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }


  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: getBannerAdUnitId()!,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
  @override
  void dispose() {
    logic.clear(); // Clear the game state
    logic.removeListener(update);
    // logic.player1Timer.stop();
    // logic.player2Timer.stop();
    _bannerAd?.dispose();
    Wakelock.disable();
    super.dispose();
  }

  // int selectedTime = 1;
  bool isDialogShown = false;

  //Widget _buildTimers() {
    // if (!isDialogShown &&
    //     (logic.player1Timer.currentTime.inSeconds <= 0 || logic.player2Timer.currentTime.inSeconds <= 0)) {
    //   isDialogShown = true;
    //  // WidgetsBinding.instance.addPostFrameCallback((_) => _showEndDialog(context));
    //   Timer(const Duration(milliseconds: 500), () => _showEndDialog(context));
    //   //_endGame(logic.turn());
    // }
    // return Column(
    //   children: [
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: [
    //         RotatedBox(
    //           quarterTurns: 2,
    //           child: Text(
    //             'White: ${logic.player1Timer.currentTime.inMinutes}:${(logic.player1Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
    //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xB3F5E3CA)),
    //           ),
    //         ),
    //         RotatedBox(
    //           quarterTurns: 2,
    //           child: Text(
    //             'Black: ${logic.player2Timer.currentTime.inMinutes}:${(logic.player2Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
    //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xB3F5E3CA)),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  //}
  //Widget _buildTimers2() {
    // if (!isDialogShown &&
    //     (logic.player1Timer.currentTime.inSeconds <= 0 || logic.player2Timer.currentTime.inSeconds <= 0)) {
    //   isDialogShown = true;
    //  // WidgetsBinding.instance.addPostFrameCallback((_) => _showEndDialog(context));
    //   Timer(const Duration(milliseconds: 500), () => _showEndDialog(context));
    //   //_endGame(logic.turn());
    // }
    // return Column(
    //   children: [
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: [
    //         Text(
    //           'White: ${logic.player1Timer.currentTime.inMinutes}:'
    //               '${(logic.player1Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
    //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xB3F5E3CA)),
    //         ),
    //         Text(
    //           'Black: ${logic.player2Timer.currentTime.inMinutes}:'
    //               '${(logic.player2Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
    //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xB3F5E3CA)),
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  //}
  Widget _buildMultiplayerBar(bool isMe, PieceColor color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            child: PlayerBar(isMe, color)
        ),
      ],
    );
  }
  Widget _buildMultiplayerBar2(bool isMe, PieceColor color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            child: RotatedBox(
                quarterTurns: 2,
                child: PlayerBar(isMe, color))
        ),
      ],
    );
  }
  bool isPromotionDialogShown = false;
  bool showEndDialog =false;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final mainPlayerColor = logic.args.asBlack ? PieceColor.BLACK : PieceColor.WHITE;
    final secondPlayerColor = logic.args.asBlack ? PieceColor.WHITE : PieceColor.BLACK;

    bool isMainTurn = mainPlayerColor == logic.turn();
    if (logic.isPromotion && (logic.args.isMultiplayer || isMainTurn) && !isPromotionDialogShown) {
      isPromotionDialogShown = true;
      Timer(const Duration(milliseconds: 10), () => _showPromotionDialog(context));
    } else if (logic.gameOver() && !showEndDialog) {
      showEndDialog =true;
      Timer(const Duration(milliseconds: 500), () => _showEndDialog(context));
    }
    return WillPopScope(
      onWillPop: () async {
        // Show the save dialog
        await _showSaveDialog(context);

        // Return false to indicate that the back action should not be handled by the system
        return false;
      },
      child: Scaffold(
          backgroundColor: color.navy1,
          body: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding:  EdgeInsets.only(top: screenHeight /15,left: screenWidth/15),
                  child: Row(
                    children: [
                      BounceButton(
                          onTap: (){
                            if (!logic.gameOver()) {
                              AudioHelper.buttonClickSound();
                              _showSaveDialog(context);
                            } else {
                              AudioHelper.buttonClickSound();
                              _showSaveDialog(context);
                              // Navigator.popUntil(context, (route) => route.isFirst);
                            }
                          },
                          height: screenHeight/20, width: screenWidth/5, duration:  Duration(milliseconds: 300),
                          child: Text('Exit',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)),

                      SizedBox(width: screenWidth/8,),
                      BouncingWidget(
                        scaleFactor: _scaleFactor,
                        onPressed: (){},
                        child: RotatedBox(
                          quarterTurns: 2,
                          // child: MaterialButton(
                          //   height: screenHeight/25,
                          //   minWidth: screenWidth/10,
                          //   onPressed:logic.canUndo() ? () => logic.undo() : null,
                          //   color: Color(0xB3F5E3CA),
                          //   child: const Icon(Icons.undo,size: 30,),),
                        ),
                      ),
                      SizedBox(width: screenWidth/8,),
                      BouncingWidget(
                        scaleFactor: _scaleFactor,
                        onPressed: (){},
                        child: RotatedBox(
                          quarterTurns: 2,
                          // child: MaterialButton(
                          //   height: screenHeight/25,
                          //   minWidth: screenWidth/10,
                          //   onPressed: logic.canRedo() ? () => logic.redo() : null,
                          //   color: Color(0xB3F5E3CA),
                          //   child: const Icon(Icons.redo,size: 30,),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //_buildTimers(),
              SizedBox(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: logic.args.isMultiplayer
                      ? _buildMultiplayerBar2(true, mainPlayerColor) //change the secondPlayerColor to MainPlayerColor
                      : PlayerBar(false, secondPlayerColor),
                ),
              ),
              // ignore: prefer_const_constructors
              BoardPiece(),
              SizedBox(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: logic.args.isMultiplayer
                      ? _buildMultiplayerBar(false, secondPlayerColor) // change the mainPlayerColor to SecondPlayerColor
                      : PlayerBar(true, mainPlayerColor),
                ),
              ),
             // _buildTimers2(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // BouncingWidget(
                  //   scaleFactor: _scaleFactor,
                  //   onPressed: (){},
                  //   child: MaterialButton(
                  //     height: screenHeight/25,
                  //     minWidth: screenWidth/10,
                  //     //onPressed:logic.canUndo() ? () => logic.undo() : null,
                  //     color: Color(0xB3F5E3CA),
                  //     child: const Icon(Icons.undo,size: 30,),),
                  // ),
                  SizedBox(width: screenWidth/8,),
                  // BouncingWidget(
                  //   scaleFactor: _scaleFactor,
                  //   onPressed: (){},
                  //   child: MaterialButton(
                  //     height: screenHeight/25,
                  //     minWidth: screenWidth/10,
                  //     onPressed: logic.canRedo() ? () => logic.redo() : null,
                  //     color: Color(0xB3F5E3CA),
                  //     child: const Icon(Icons.redo,size: 30,),),
                  // ),
                ],
              ),
              // if (_isBannerAdReady)
              //   Container(
              //     alignment: Alignment.center,
              //     width: _bannerAd!.size.width.toDouble(),
              //     height: _bannerAd!.size.height.toDouble(),
              //     child: AdWidget(ad: _bannerAd!),
              //   ),

            ],
          )
      ),
      // )
    );
  }

  Future<void> _showSaveDialog(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            AlertDialog(
                backgroundColor: Color(0xB3F5E3CA),
                title:  Align(
                  alignment: Alignment.topCenter,
                  child: Text("Exit",
                      style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
                ),
                // content: Text("Do you want to Exit this game?",
                //     style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: Colors.yellow)),
                actions: [
                  TextButton(
                    onPressed: () {
                      AudioHelper.buttonClickSound();
                      // logic.player1Timer.stop();
                      // logic.player2Timer.stop();
                      Navigator.pop(context);
                      // logic.clear();
                      // Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text("No",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                  TextButton(
                    onPressed: () {
                      _showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      final args = logic.args;
                      logic.clear();
                      args.asBlack = !args.asBlack;
                      logic.args = args;
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/localGame1');
                      logic.start();
                    },
                    child: Text("Rematch",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                  TextButton(
                    onPressed: () async {
                      _showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      logic.clear();
                      // Navigator.popUntil(context, (route) => route.isFirst);
                      // logic.player1Timer.stop();
                      // logic.player2Timer.stop();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
                    },
                    child: Text("Yes",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                ]
            )
    );
  }

  void _showEndDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var title = "";
    if (logic.inCheckmate()) {
      title = "Checkmate!\n${logic.turn() == PieceColor.WHITE
          ? "Black"
          : "White"} Wins";
    } else if (logic.inDraw()) {
      title = "Draw!\n";
      if (logic.insufficientMaterial()) {
        title += "By Insufficient Material";
      } else if (logic.inThreefoldRepetition()) {
        title += "By Repetition";
      } else if (logic.inStalemate()) {
        title += "By Stalemate";
      } else {
        title += "By the 50-move rule";
      }
    } else {
     // var winner = logic.determineWinner();
     // title = "Time's up!\n${winner == PieceColor.WHITE ? "White" : "Black"} Wins";
    }

    // else {
    //   title = "Time's up!\n${logic.turn() == PieceColor.WHITE
    //       ? "Black"
    //       : "White"} Wins";
    // }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            AlertDialog(
                backgroundColor: Color(0xB3F5E3CA),
                title: Text(title,
                    style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
                actions: [
                  TextButton(
                    onPressed: () {
                      AudioHelper.buttonClickSound();
                      // logic.player1Timer.stop();
                      // logic.player2Timer.stop();
                      Navigator.pop(context);
                      // logic.clear();
                      // Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text("No",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                  TextButton(
                    onPressed: () {
                      _showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      final args = logic.args;
                      logic.clear();
                      args.asBlack = !args.asBlack;
                      logic.args = args;
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/localGame1');
                      logic.start();
                    },
                    child: Text("Rematch",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                  TextButton(
                    onPressed: () async {
                      _showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      logic.clear();
                      //  Navigator.popUntil(context, (route) => route.isFirst);
                      // logic.player1Timer.stop();
                      // logic.player2Timer.stop();
                      Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                      showEndDialog = false;
                    },
                    child: Text("Exit",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  )
                ]));
   // showEndDialog =false;
   // isDialogShown = false;
  }

  void _showPromotionDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var pieces = [
      PieceType.QUEEN,
      PieceType.ROOK,
      PieceType.BISHOP,
      PieceType.KNIGHT
    ].map((pieceType) => Piece(pieceType, logic.turn()));
    final asBlack = logic.args.asBlack;
    var futureValue = showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Transform.rotate(
            angle: (logic.turn() == PieceColor.BLACK) != asBlack
                ? math.pi
                : 0,
            child: SimpleDialog(
                title: Text('Promote to',
                    style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                shadowColor: Colors.green,
                //backgroundColor: Colors.grey,
                surfaceTintColor: Colors.green,
                children: pieces
                    .map((piece) => SimpleDialogOption(
                    onPressed: () => Navigator.of(context).pop(piece),
                    child: SizedBox(
                        height: 60,
                        child: PieceWidget(piece: piece)
                    )))
                    .toList())));
    // futureValue.then((piece) => logic.promote(piece));
    futureValue.then((piece) {
      logic.promote(piece);
      isPromotionDialogShown = false; // Reset the flag
    });

  }
}


String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
   // return 'ca-app-pub-6174775436583072/8733467494';
  }
  return null;
}
