
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/buttons/bounce_button.dart';
import 'package:chess_game/games/board_piece.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:io';
import '../screen/home_screen.dart';
import 'piece_widget.dart';
import 'package:flutter/material.dart';
import 'player_bar.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:chess_game/colors.dart';
import 'package:get_it/get_it.dart';
import 'game_logic.dart';
final logic = GetIt.instance<GameLogic>();
const String testDevice = 'YOUR_DEVICE_ID';
const int maxFailedLoadAttempts = 3;
class LocalGame2 extends StatefulWidget {
  const LocalGame2({super.key});

  @override
  State<LocalGame2> createState() => _LocalGame2State();
}

class _LocalGame2State extends State<LocalGame2> {
  void update() => setState(() => {});

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  @override
  void initState() {
    logic.addListener(update);
    super.initState();
    MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [testDevice]));
    _createInterstitialAd();
    _loadBannerAd();
    Wakelock.enable();
  }
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId:
        //getInterstitialAdUnitId()!,
        Platform.isAndroid
            ? 'ca-app-pub-6174775436583072/1262806049'
        //'ca-app-pub-7319269804560504/6941421099'
            : 'ca-app-pub-7319269804560504/3520838807',
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
  Future<void> dispose() async {
    logic.removeListener(update);
    Wakelock.disable();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('selected_color'); // Clear the selected color
    super.dispose();
  }

  Widget _buildMultiplayerBar(isMe, PieceColor color) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              child: PlayerBar(isMe, color)
          ),
        ]
    );
  }
  Widget _buildMultiplayerBar2(isMe, PieceColor color) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              child: RotatedBox(
                  quarterTurns: 2,
                  child: PlayerBar(isMe, color)
              )),
        ]
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
          await _showSaveDialog(context);
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
                    child: BounceButton(
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
                  ),
                ),
                SizedBox(height: screenHeight/25,),
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
                SizedBox(height: screenHeight/50,),
                // if (_isBannerAdReady)
                //   Container(
                //     alignment: Alignment.center,
                //     child: AdWidget(ad: _bannerAd!),
                //     width: _bannerAd!.size.width.toDouble(),
                //     height: _bannerAd!.size.height.toDouble(),
                //   ),
              ]
          ),
        )
      // )
    );
  }
  Future<void> _showSaveDialog(BuildContext context) async{
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            AlertDialog(
                backgroundColor: Color(0xB3F5E3CA),
                title: Text("Quit! Game",
                    style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
                //  content: const Text("Do you want to Exit this game?"),
                actions: [
                  Column(
                    children: [
                      Row(
                        children: [
                          ClipPath(
                              clipper: ParallelogramClipper(),
                              child: Container(
                                height: screenHeight/20,
                                width: screenWidth/5,
                                color: color.navy1,
                                child: TextButton(
                                  onPressed: () {
                                    AudioHelper.buttonClickSound();
                                    Navigator.pop(context);
                              // logic.clear();
                              // Navigator.popUntil(context, (route) => route.isFirst);
                            },
                                  child:  Text("No",
                                style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/20,color: Colors.white)),
                                 ),)),
                          ClipPath(
                              clipper: ParallelogramClipper(),
                              child: Container(
                              height: screenHeight/20,
                              width: screenWidth/4,
                              color: color.navy1,
                                child: TextButton(
                                  onPressed: () {
                                    _showInterstitialAd();
                                    AudioHelper.buttonClickSound();
                                    final args = logic.args;
                                    logic.clear();
                                    args.asBlack = !args.asBlack;
                                    logic.args = args;
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/localGame2');
                                    logic.start();
                                    },
                                  child: Text("Rematch",
                                style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/20,color: Colors.white)),
                          ),))
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      _showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      logic.clear();
                      // showVideoAd();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: Text("Yes",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                  TextButton(
                    onPressed: () {
                      final game = logic.save();
                      logic.clear();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                      final snackBar = SnackBar(
                        /// backgroundColor: Theme.of(context).bottomAppBarColor ,
                          content: Text(
                              "The game has been saved as ${game.name}",
                              style: TextStyle(color: Theme.of(context).primaryColorLight))
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child:  Text("save",style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                ]
            )
    );
  }

  void _showEndDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var title = "";
    if (logic.inCheckmate()) {
      title = "Checkmate!\n${logic.turn() == PieceColor.WHITE ? "Black" : "White"} Wins";
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
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            AlertDialog(
                backgroundColor: Color(0xB378C5A5),
                title: Text(title,
                    style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
                actions: [
                  Column(
                    children: [
                      Row(
                        children: [
                          ClipPath(
                          clipper: ParallelogramClipper(),
                          child: Container(
                            height: screenHeight/20,
                            width: screenWidth/5,
                            color: color.navy1,
                            child: TextButton(
                              onPressed: () {
                                AudioHelper.buttonClickSound();
                                // logic.player1Timer.stop();
                                // logic.player2Timer.stop();
                                Navigator.pop(context);
                                // logic.clear();
                                // Navigator.popUntil(context, (route) => route.isFirst);
                              },
                              child: Text("No",
                                  style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: Colors.white)),
                            ),
                          )),
                           ClipPath(
                              clipper: ParallelogramClipper(),
                              child: Container(
                              height: screenHeight/20,
                              width: screenWidth/5,
                              color: color.navy1,
                          child: TextButton(
                            onPressed: () {
                              _showInterstitialAd();
                              AudioHelper.buttonClickSound();
                              final args = logic.args;
                              logic.clear();
                              args.asBlack = !args.asBlack;
                              logic.args = args;
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/localGame2');
                              logic.start();
                            },
                            child: Text("Rematch",
                                style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: Colors.white)),),
    ))
                        ],
                      ),
                    ],
                  ),

                  TextButton(
                    onPressed: () async {
                      _showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      logic.clear();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: Text("Exit",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                  TextButton(
                    onPressed: () {
                      final game = logic.save();
                      logic.clear();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                      final snackBar = SnackBar(
                        /// backgroundColor: Theme.of(context).bottomAppBarColor ,
                          content: Text(
                              "The game has been saved as ${game.name}",
                              style: TextStyle(color: Theme.of(context).primaryColorLight))
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: Text("save",style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                ]));
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
              // shadowColor: Colors.green,
                backgroundColor: Color(0xB378C5A5),
                // surfaceTintColor: Colors.green,
                title: Text('Promote to',
                    style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                children: pieces
                    .map((piece) => SimpleDialogOption(
                    onPressed: () => Navigator.of(context).pop(piece),
                    child: SizedBox(
                        height: 64,
                        child: PieceWidget(piece: piece)
                    )))
                    .toList())));
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


class ParallelogramClipper extends CustomClipper<Path> {
  //final double borderSize;
  final Color borderColor;

  ParallelogramClipper({
    //this.borderSize = 5.0,
    this.borderColor = color.blue3});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.1, 0); // Move to top left with an offset
    path.lineTo(size.width, 0); // Line to top right
    path.lineTo(size.width * 0.9, size.height); // Line to bottom right with an offset
    path.lineTo(0, size.height); // Line to bottom left
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}