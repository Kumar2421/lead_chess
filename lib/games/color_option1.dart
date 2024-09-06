
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'piece_widget.dart';
import 'dart:io' show Platform;
import 'package:get_it/get_it.dart';
import 'game_logic.dart';
final logic = GetIt.instance<GameLogic>();
const String testDevice = 'YOUR_DEVICE_ID';
const int maxFailedLoadAttempts = 3;
class ColorOption1 extends StatefulWidget{
  const ColorOption1 ({super.key});

  @override
  State<ColorOption1> createState() => _ColorOption1State();
}

class _ColorOption1State extends State<ColorOption1> {
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  bool isLoadingAd = false;
  @override
  void initState() {
    super.initState();
    MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [testDevice]));
    _createInterstitialAd();
  }
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId:
        //getInterstitialAdUnitId()!,
        Platform.isAndroid
            ?
        //'ca-app-pub-6174775436583072/1262806049'
        'ca-app-pub-7319269804560504/6941421099'
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
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.navy1,
       // leading: ArrowBackButton(color: Colors.white,),
      ),
      body: Center(
        child:  Container(
          height: screenHeight,
          width: screenWidth,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [color.navy, Colors.black],
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                    child: Container(
                      width: screenWidth / 3.6,
                      height: screenHeight / 6.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey,
                      ),
                      child: SizedBox(
                        width: screenWidth / 3.6,
                        height: screenHeight / 7,
                        child: PieceWidget(piece: Piece(PieceType.KING, PieceColor.BLACK)),
                      ),
                    ),
                    onTap: ()  {
                     // _showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      logic.args.asBlack = true;
                      final args = ModalRoute.of(context)!.settings.arguments;
                      print('Arguments received in route: $args'); // Debug print
                      final selectedTime = args is int ? args : 1;
                      Navigator.pushNamed(context, '/localGame1',arguments: selectedTime,);
                      print('Navigating to /localGame1 with selectedTime: $selectedTime'); // Debug print
                      logic.start();
                    }
                ),
              ),
              Flexible(
                child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                    child: SizedBox(
                      width: screenWidth / 3.6,
                      height: screenHeight / 7,
                      child: PieceWidget(piece: Piece(PieceType.KING, PieceColor.WHITE)),
                    ),
                    onTap: ()  async {
                    //  _showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      logic.args.asBlack = false;
                      final args = ModalRoute.of(context)!.settings.arguments;
                      print('Arguments received in route: $args'); // Debug print
                      final selectedTime = args is int ? args : 1;
                      Navigator.pushNamed(context, '/localGame1',arguments: selectedTime,);
                      print('Navigating to /localGame1 with selectedTime: $selectedTime'); // Debug print
                      logic.start();
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
