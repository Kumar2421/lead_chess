
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:chess_game/games/color_option1.dart';
import 'package:chess_game/games/color_option2.dart';
import 'package:chess_game/games/game_logic.dart';
import 'package:chess_game/games/local_game_page1.dart';
import 'package:chess_game/games/local_game_page2.dart';
import 'package:chess_game/games/skills_option1.dart';
import 'package:chess_game/games/skills_option2.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:chess_game/server_side/websocket_manager.dart';
import 'package:chess_game/spin_wheel.dart';
import 'package:chess_game/splash_screen.dart';
import 'package:chess_game/user/current_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'games/game_screen.dart';
import 'games/resume_screen.dart';
import 'notification_page.dart';


const kWebRecaptchaSiteKey = "AIzaSyBYsklEXh8FvrcDuxX1c6GzwKz3SmSZuo4";
//'AIzaSyAlQloKdaZyZ07q653fAWogE1swGdohGzA';
List<CameraDescription> cameras = [];

Future<void> main() async {
  GetIt.instance.registerSingleton<GameLogic>(GameLogicImplementation(), signalsReady: true);

  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  MobileAds.instance.initialize();
  // SystemChrome.setPreferredOrientations([
  //       DeviceOrientation.landscapeRight,
  //       DeviceOrientation.landscapeLeft,
  //       DeviceOrientation.portraitUp,
  //       DeviceOrientation.portraitDown
  //     ]);
 // final notificationService = NotificationService();
 // notificationService.init();
  await NotificationService.initializeLocalNotifications();
 // await NotificationController.initializeLocalNotifications();
 // await NotificationController.initializeIsolateReceivePort();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  ));
  Get.put(UserController());
  runApp(
   // const MyApp(),
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerService()),
      ],
      child: MyApp(),
    ),
  );
}

late WebSocketManager webSocketManager;
late SharedPreferences prefs; // SharedPreferences instance

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Material(
      child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
       child:FutureBuilder(
       future: initPrefs(),
       builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.done) {
         _initializeWebSocketManager();
          return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              initialBinding: BindingsBuilder(() {
                Get.put(CurrentUser());
              }),
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.white,
              ),
              home: const Splashscreen(),
              // initialRoute: '/',
              routes: {
                //'/': (context) => Splashscreen(),
                '/homescreen': (context) => HomeScreen(),
                '/skillsOption1': (context) => SkillsOption1(),
                '/skillsOption2': (context) => SkillsOption2(),
                '/colorOption1': (context) => ColorOption1(),
                '/colorOption2': (context) => ColorOption2(),
                '/resume': (context) => ResumeScreen(),
               // '/localGame1': (context) => LocalGame1(),
                '/localGame1': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments;
                  final selectedTime = args is int ? args : 1; // Default to 5 if args is null or not an int
                  return LocalGame1(selectedTime: selectedTime);
                },
                '/localGame2': (context) => LocalGame2(),
                '/game': (context) => const GameScreen(),
              //  '/game2': (context) => const ChooseColorScreen2(),
              }
          );
    } else {
         return const CircularProgressIndicator(); // Or any loading indicator
       }
    }
          )
    )
    );
  }
  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _initializeWebSocketManager() async {
    // Retrieve session token from local storage
    String? sessionToken = prefs.getString('sessionToken');
    print('Retrieved session token: $sessionToken');

    // Check if sessionToken is not null or empty before initializing WebSocketManager
    if (sessionToken != null && sessionToken.isNotEmpty) {
      // Initialize WebSocketManager with the session token
      webSocketManager = WebSocketManager('ws://192.168.29.168:3005');
      webSocketManager.init('ws://192.168.29.168:3005');

      // Register the WebSocketManager as a singleton
      GetIt.instance.registerSingleton<WebSocketManager>(webSocketManager);

      // Print a debug message before sending user_info message
      print('Sending user_info message with session token: $sessionToken');

      // Send user information to the server upon initialization
      webSocketManager.send(json.encode({
        'type': 'test_message',
        'sessionToken': sessionToken,
      }));
    } else {
      print('Invalid session token. Skipping WebSocketManager initialization.');
    }
  }
}

