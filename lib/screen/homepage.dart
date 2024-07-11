import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:add_to_cart_animation/add_to_cart_icon.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:button_animations/button_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../buttons/back_button.dart';
import '../colors.dart';
import '../games/board_piece.dart';
import '../games/color_option1.dart';
import '../games/game_logic.dart';
import '../games/timer.dart';
import '../notification_page.dart';
import '../play_online.dart';
import '../profile_page.dart';
import '../setting_page.dart';
import '../spin_wheel.dart';
import '../user/current_user.dart';
import '../user/total_amount_model.dart';
import '../user/users.dart';

final logic = GetIt.instance<GameLogic>();
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin{
  final GlobalKey widgetKey = GlobalKey();
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
 // late Function(GlobalKey) runAddToCartAnimation;
  Function(GlobalKey)? runAddToCartAnimation;
  var _cartQuantityItems = 0;
  final double _scaleFactor = 1.0;
  late Map<String, dynamic> userData = {};
  Users currentUser = Get.find<CurrentUser>().users;
  String? _profilePicturePath;
  String? _userId;
  String? _totalAmount;
  String? _totalMoney;
  final UserController userController = Get.find<UserController>();

  int totalRewardAmount = 0;
  int totalMoney = 0;
  int rewardedCount = 0;

  void simulateDollarImageClick() {
    runAddToCartAnimation!(widgetKey);
  }
  void listClick(GlobalKey widgetKey) async {
    await runAddToCartAnimation!(widgetKey);
    await cartKey.currentState!
        .runCartAnimation((++_cartQuantityItems).toString());
  }

  late TotalAmount totalAmount = TotalAmount(
    id: "",
    userId: "",
    totalRewardAmount: "",
    totalMoney: "",
  );
  Future<TotalAmount?> insertIntoCoinsTable(String userId, int totalRewardAmount, int totalMoney,) async {
    try {
      // var url = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/total_reward_amount.php');
      var url = Uri.parse('https://schmidivan.com/Esakki/ChessGame/total_reward_amount');
      var body = {
        'user_id': userId,
        'total_amount': totalRewardAmount.toString(),
        'total_money': totalMoney.toString(), // Convert totalMoney to String
      };

      // Send HTTP POST request
      var response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        print('Data inserted into coins table successfully');
        return TotalAmount.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to insert data into coins table: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error inserting data into coins table: $e');
      return null;
    }
  }

  Future<void> fetchUserData(String userId) async {
    try {
      // var url = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/fetch_amount.php');
      var url = Uri.parse('https://schmidivan.com/Esakki/ChessGame/fetch_amount');
      var response = await http.post(url, body: {'user_id': userId});

      if (response.statusCode == 200) {
        // Parse JSON response
        var userData = jsonDecode(response.body);
        setState(() {
          _totalAmount = userData['total_amount'];
          _totalMoney = userData['total_money'];
        });
        print('Total Amount: $_totalAmount');
        print('Total Money: $_totalMoney');
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }


  Future<void> fetchProfilePicturePath(String userId, String email) async {
    try {
      final response = await http.post(
        // Uri.parse('https://leadproduct.000webhostapp.com/chessApi/fetch_profile_picture.php'),
        Uri.parse('https://schmidivan.com/Esakki/ChessGame/fetch_profile_picture'),
        body: {
          'user_id': userId,
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if the imagePath key exists in the response data
        if (!mounted) return;
        if (responseData.containsKey('imagePath')) {
          final String imagePath = responseData['imagePath'];

          // Assuming imagePath contains the file name only, concatenate it with the base URL
          // const String baseUrl = 'https://leadproduct.000webhostapp.com/chessApi/';
          const String baseUrl = 'https://schmidivan.com/Esakki/ChessGame/';
          final String imageUrl = baseUrl + imagePath;

          setState(() {
            _userId = userId;
            _profilePicturePath =  'https://schmidivan.com/Esakki/ChessGame/$imagePath'; // Update _profilePicturePath with the complete URL
          });
        } else {
          // Handle case where no image path is found
          setState(() {
            _userId = null;
            _profilePicturePath = null; // Set _profilePicturePath to null or a default image URL
          });
        }
      } else {
        throw Exception('Failed to fetch image data');
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(currentUser.userId);
    MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [testDevice]));
    _createRewardedAd();
    insertIntoCoinsTable(currentUser.userId, totalRewardAmount, totalMoney);
    fetchProfilePicturePath(currentUser.userId, currentUser.email);
    //     .then((_) {
    //   setState(() {
    //     _profilePicturePath = _profilePicturePath;
    //   });
    // });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-7319269804560504/6645907620'
            : 'ca-app-pub-7319269804560504/2207757133',
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) async {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
        // Call the function to update coins and perform other actions
        await insertIntoCoinsTable(currentUser.userId, totalRewardAmount, totalMoney);
        await fetchUserData(currentUser.userId);
        await Future.delayed(Duration(milliseconds: 100));
        simulateDollarImageClick();
        simulateDollarImageClick();
        simulateDollarImageClick();
        for (int i = 0; i < 5; i++) {
          await Future.delayed(Duration(microseconds: 100));
          simulateDollarImageClick();
          simulateDollarImageClick();
          simulateDollarImageClick();
        }

        // Update the state to reflect the changes in the UI
        setState(() {});
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
        });
    _rewardedAd = null;
  }
  @override
  void dispose() {
    // interstitialAd.dispose();
    // rewardAd.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
  Future<void> updateGameMode(String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('game_mode', mode);
  }

// Handler for "Play Local" button
  void handlePlayLocal(BuildContext context) {
    AudioHelper.buttonClickSound();
    updateGameMode('local'); // Update shared preferences with 'local'
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TimerOptionPage()));
  }

// Handler for "Play Online" button
  void handlePlayOnline(BuildContext context) {
    AudioHelper.buttonClickSound();
    updateGameMode('online'); // Update shared preferences with 'online'
    logic.args.isMultiplayer = true; // Optional: Set multiplayer flag
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PlayOnline2()));
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    // return GetBuilder(                  //
    //   init: CurrentUser(),              //
    //   initState: (currentState){              //
    //     _rememberCurrentUser.getUserInfo();   //
    //   },
    //   builder: (controller) {
    return AddToCartAnimation(
        cartKey: cartKey,
        height: 30,
        width: 30,
        opacity: 0.85,
        dragAnimation: const DragToCartAnimationOptions(
        rotation: false,
     ),
        jumpAnimation: const JumpAnimationOptions(),
        createAddToCartAnimation: (runAddToCartAnimation) {
          this.runAddToCartAnimation = runAddToCartAnimation;
          },
        child: Container(
              height: screenHeight / 1,
              width: screenWidth / 1,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/home.jpeg'),
                      fit: BoxFit.cover)),
              child: SingleChildScrollView(
                //physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                //BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProfilePage()));
                            },
                            child: FlutterColorsBorder(
                                available: true,
                                size: Size(screenWidth/8,screenHeight/18),
                                boardRadius: 50,
                                child:SizedBox(
                                  height: 50,
                                  width: 50,
                                  child:
                                  // Obx(() {
                                  //   return userController.profilePicturePath.value.isNotEmpty
                                  //       ? CircleAvatar(
                                  //     radius: 50.0,
                                  //     backgroundImage: NetworkImage(userController.profilePicturePath.value),
                                  //       onBackgroundImageError: (_, __) {
                                  //         setState(() {
                                  //           userController.deleteProfilePicturePath();
                                  //          // userController.profilePicturePath.value.isEmpty;
                                  //         //  _profilePicturePath = null;
                                  //         });
                                  //       },
                                  //   )
                                  //       : CircleAvatar(
                                  //     radius: 50.0,
                                  //     child: Icon(Icons.person),
                                  //   );
                                  // }),
                                  _profilePicturePath != null
                                      ? CircleAvatar(
                                    radius: 50.0,
                                    backgroundImage: NetworkImage(_profilePicturePath!), // Use _profilePicturePath directly
                                    onBackgroundImageError: (_, __) {
                                      setState(() {
                                        _profilePicturePath = null;
                                      });
                                    },
                                  )
                                      : const CircleAvatar(
                                    radius: 50.0, child: Icon(Icons.person),),
                                  )
                            ),
                          ),
                          Container(
                            height: screenHeight/32,
                            width: screenWidth/4,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: color.navy
                            ),
                            child: Row(
                              children: [
                                Image(image: const AssetImage('assets/money1.png'),
                                  height: screenHeight/20,
                                  width: screenWidth/16,),
                                SizedBox(
                                  height: screenHeight/32,
                                  width: screenWidth/7,
                                  child:  Center(
                                    child: Text('$_totalMoney',
                                      style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w500,color: Colors.white),
                                    ),
                                  ),
                                ),
                                Image(image: const AssetImage('assets/plus1.png'),
                                  height: screenHeight/28, width: screenWidth/23,),
                              ],
                            ),
                          ),
                          Container(
                            height: screenHeight / 32,
                            width: screenWidth / 4,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: color.navy
                            ),
                            child: Row(
                              children: [
                                Container(
                                  key: cartKey,
                                  child: Image(image: const AssetImage('assets/Dollar.png'),
                                    height: screenHeight / 25,
                                    width: screenWidth / 18,
                                  ),
                                ),
                                SizedBox(
                                    height: screenHeight / 32,
                                    width: screenWidth / 7.5,
                                    child: Center(
                                        child: Text('$_totalAmount',
                                          style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w500,color: Colors.white),))),
                                Image(image: const AssetImage('assets/plus1.png'),
                                  height: screenHeight / 28,
                                  width: screenWidth / 23,),
                              ],
                            ),
                          ),

                          IconButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const SettingPage()));
                          }, icon: const Icon(Icons.settings,color: Colors.grey,)),
                        ],
                      ),
                      Gap(screenHeight/100),
                      Gap(screenHeight / 25),
                      Image(image: const AssetImage('assets/LC-logo1.png'),
                        height: screenHeight / 10,
                        width: screenWidth / 3,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('LEAD', style: GoogleFonts.oswald(
                              color: Colors.white,
                              fontSize: screenWidth / 9,
                              fontWeight: FontWeight.bold),),
                          Gap(screenWidth / 50),
                          Text('CHESS', style: GoogleFonts.oswald(
                              fontSize: screenWidth / 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.amberAccent),),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          height: screenHeight / 400,
                          width: screenWidth / 2.2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.amber, Colors.white],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                        ),),
                      Gap(screenHeight / 15),
                     // const CyberButtons(),
                    //  Gap(screenHeight / 25),
                      AnimatedButton(
                        type: null,
                        blurRadius: 10,
                        height: screenHeight/20,
                        width: screenWidth/2.5,
                        shadowColor:  color.blue3,
                        color: color.navy,
                        //borderColor: color.navy,
                        // blurColor: color.beige2,
                        onTap: () {
                          handlePlayLocal(context);
                          // AudioHelper.buttonClickSound();
                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> TimerOptionPage()));
                        },
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Gap(screenWidth/100),
                            Image(
                              image: const AssetImage('assets/chesscoin.png'),
                              height: screenHeight/35,width: screenWidth/18,color: Colors.orangeAccent,),
                            Gap(screenWidth/100),
                            Text(
                              'Play Local',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: screenWidth/30),
                            ),
                          ],
                        ),
                      ),
                      Gap(screenHeight / 25),
                      AnimatedButton(
                        type: null,
                        blurRadius: 10,
                        height: screenHeight/20,
                        width: screenWidth/2.5,
                        shadowColor:  color.blue3,
                        color: color.navy,
                        //borderColor: color.navy,
                        // blurColor: color.beige2,
                        onTap: () {
                          AudioHelper.buttonClickSound();
                          logic.args.isMultiplayer = false;
                          Navigator.pushNamed(context, '/skillsOption2');
                        },
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Gap(screenWidth/100),
                            Image(
                              image: const AssetImage('assets/chesscoin.png'),
                              height: screenHeight/35,width: screenWidth/18,color: Colors.orangeAccent,),
                            Gap(screenWidth/100),
                            Text(
                              'Play With AI',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: screenWidth/30),
                            ),
                          ],
                        ),
                      ),
                      Gap(screenHeight / 25),
                      AnimatedButton(
                        type: null,
                        blurRadius: 10,
                        height: screenHeight/20,
                        width: screenWidth/2.5,
                        shadowColor:  color.blue3,
                        color: color.navy,
                        //borderColor: color.navy,
                        // blurColor: color.beige2,
                        onTap: () {
                          handlePlayOnline(context);
                          //AudioHelper.buttonClickSound();
                          // logic.args.isMultiplayer = true;
                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> PlayOnline2()));
                        },
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Gap(screenWidth/100),
                            Image(
                              image: const AssetImage('assets/chesscoin.png'),
                              height: screenHeight/35,width: screenWidth/18,color: Colors.orangeAccent,),
                            Gap(screenWidth/100),
                            Text(
                              'Play Online',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: screenWidth/30),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight/5,),
                      Padding(
                        padding:  EdgeInsets.only(right: screenWidth/35,left: screenWidth/35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RewardDialog(onClick: listClick),
                        BouncingWidget(
                          scaleFactor: _scaleFactor,
                          onPressed: () async {
                            _showRewardedAd();
                          },
                          child: ClipPath(
                            clipper: ParallelogramClipper(),
                            child: Container(
                              height: screenHeight/15,
                              width: screenWidth/3.5,
                              decoration: BoxDecoration(
                                color: color.navy1,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: color.navy.withOpacity(0.99), width: 10.0
                                  //   bottom: BorderSide(color: color.navy1, width: 3.0), // Set the border color and width for the bottom side
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('100',style: TextStyle(color: Colors.white,fontSize: screenWidth/25,fontWeight: FontWeight.bold),),
                                  Container(
                                    key: widgetKey,
                                    child: Image(
                                      image: AssetImage('assets/Dollar.png'),height: screenHeight/15,width: screenWidth/25,),
                                  ),
                                  Text(
                                    'Ads',
                                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: screenWidth/32),),
                                  Image(
                                    image: AssetImage('assets/arrowf1.png'),height: screenHeight/35,width: screenWidth/30,color: Colors.white,),
                                ],
                              ),
                            ),
                          ),
                        ),
                            // BouncingWidget(
                            //   scaleFactor: _scaleFactor,
                            //   onPressed: () => _showOptionsDialog(context),
                            //   // child: Padding(
                            //   //   padding: EdgeInsets.only(left: screenWidth/13),
                            //     child:Image(
                            //       image: const AssetImage('assets/gift.png'),
                            //       height:screenHeight/15,width: screenWidth/8,fit: BoxFit.cover,),
                            // //  ),
                            // ),
                            BouncingWidget(
                              scaleFactor: _scaleFactor,
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>Spin())),
                              // child: Padding(
                              //   padding: EdgeInsets.only(left: screenWidth/13),
                                child:ClipPath(
                                  clipper: ParallelogramClipper(),
                                  child: Container(
                                    height: screenHeight/15,
                                    width: screenWidth/3.5,
                                    decoration: BoxDecoration(
                                      color: color.navy1,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: color.navy.withOpacity(0.99), width: 10.0
                                        //   bottom: BorderSide(color: color.navy1, width: 3.0), // Set the border color and width for the bottom side
                                      ),
                                    ),
                                    child: Image(
                                      image: AssetImage('assets/spin.png'),
                                      height:screenHeight/20,width: screenWidth/10,),
                                  ),
                                ),
                             // ),
                            ),

                          ],
                        ),
                      ),
                    ]
                ),
              ),
      )
          );
  }
  void _showOptionsDialog(BuildContext context,) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;
        return  AddToCartAnimation(
          cartKey: cartKey,
          height: 30,
          width: 30,
          opacity: 0.85,
          dragAnimation: const DragToCartAnimationOptions(
            rotation: true,
          ),
          jumpAnimation: const JumpAnimationOptions(),
          createAddToCartAnimation: (runAddToCartAnimation) {
            this.runAddToCartAnimation = runAddToCartAnimation;
          },

          child: AlertDialog(
            backgroundColor: Colors.blue.withOpacity(0.5),
            title: Row(
              children: [
                const Text('Free Coins',style: TextStyle(color: Colors.white),),
                SizedBox(width: screenWidth/5,),
                // Material(
                //   color: Colors.transparent,
                //   child:
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: screenHeight/25,
                      width: screenWidth/15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red, // Change this to your desired color
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
              //  ),
              ],
            ),
            content: SizedBox(
              // width: screenWidth * 0.8,
              // height: screenHeight * 0.4,
              width: screenWidth /1.2,
              height: screenHeight/2.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
               //   RewardDialog(),
                  SizedBox(height: screenHeight/20,),
                  Container(
                    height: screenHeight/10,
                    width: screenWidth/1.5,
                    decoration: BoxDecoration(
                      color: color.navy1,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: color.navy.withOpacity(0.99), width: 10.0
                        //   bottom: BorderSide(color: color.navy1, width: 3.0), // Set the border color and width for the bottom side
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('100',style: TextStyle(color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold),),
                        GestureDetector(
                          //  onTap: () =>runAddToCartAnimation(widgetKey),
                          child: Container(
                            key: widgetKey,
                            width: screenWidth/25,
                            height: screenHeight/15,
                            color: Colors.transparent,
                            child: const Image(
                              image: AssetImage('assets/Dollar.png'),
                            ),
                          ),
                        ),
                        Container(
                          height: screenHeight/25,
                          width: screenWidth/3,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: MaterialButton(
                            onPressed: () async {
                              _showRewardedAd();
                            },
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reward Collect',
                                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: screenWidth/32),
                                ),
                                Image(
                                  image: AssetImage('assets/arrowf1.png'),height: screenHeight/35,width: screenWidth/30,color: Colors.white,),
                                //Icon(Icons.video_library_outlined,size: 30,color: Colors.green,)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
    //return 'ca-app-pub-6174775436583072/8733467494';
  }
  return null;
}

String? getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/4411468910';
  } else if (Platform.isAndroid) {
   return 'ca-app-pub-3940256099942544/1033173712';
   // return 'ca-app-pub-6174775436583072/1262806049';
  }
  return null;
}

String? getRewardBasedVideoAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/1712485313';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/5224354917';
   //  return 'ca-app-pub-6174775436583072/1937647367';
  }
  return null;
}


class ParallelogramClipper extends CustomClipper<Path> {
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



class RewardDialog extends StatefulWidget {
  final void Function(GlobalKey)? onClick;
  RewardDialog({super.key, required this.onClick});

  @override
  _RewardDialogState createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> {
  final GlobalKey widgetKey = GlobalKey();
  late Timer _timer;
  final double _scaleFactor = 1.0;
  int totalRewardAmount = 10;
  int totalMoney = 0;
  int rewardedCount = 0;
  Users currentUser = Get.find<CurrentUser>().users;
  late TotalAmount totalAmount = TotalAmount(
    id: "",
    userId: "",
    totalRewardAmount: "",
    totalMoney: "",
  );

  Future<TotalAmount?> insertIntoCoinsTable(String userId, int totalRewardAmount, int totalMoney,) async {
    try {
      var url = Uri.parse('https://schmidivan.com/Esakki/ChessGame/free_coins');
      var body = {
        'user_id': userId,
        'total_amount': totalRewardAmount.toString(),
        'total_money': totalMoney.toString(),
      };

      var response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        print('Data inserted into coins table successfully');
        return TotalAmount.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to insert data into coins table: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error inserting data into coins table: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize _timer with a dummy timer to avoid LateInitializationError
    _timer = Timer(Duration(seconds: 0), () {});
  //  _loadState();
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return    BouncingWidget(
        scaleFactor: _scaleFactor,
      onPressed: (){},
      child: ClipPath(
        clipper: ParallelogramClipper(),
      child:  Container(
      height: screenHeight / 15,
      width: screenWidth / 3.5,
      decoration: BoxDecoration(
        color: color.navy1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: color.navy.withOpacity(0.99), width: 10.0
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (timerService.rewardDialogTimerActive)
            Text(
              _formatDuration(timerService.rewardDialogRemainingTime),
              style: TextStyle(fontSize: 30,color: Colors.white),
            )
          else
            ClipPath(
              clipper: ParallelogramClipper(),
              child: MaterialButton(
                onPressed: () async {
                  widget.onClick!(widgetKey);
                  timerService.startRewardDialogTimer(Duration(minutes: 1));
                  await insertIntoCoinsTable(currentUser.userId, totalRewardAmount, totalMoney);
                },
                color: Colors.orange,
                child: Row(
                  children: [
                    const Text(
                      '10',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onClick!(widgetKey),
                      child: Container(
                        key: widgetKey,
                        child: Image(
                          image: AssetImage('assets/Dollar.png'),  width: screenWidth/20, height: screenHeight/15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      )
      )
    );
  }
}
