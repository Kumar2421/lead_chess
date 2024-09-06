
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:chess_game/games/color_option1.dart';
import 'package:chess_game/games/color_option2.dart';
import 'package:chess_game/games/game_logic.dart';
import 'package:chess_game/games/local_game_page1.dart';
import 'package:chess_game/games/local_game_page2.dart';
import 'package:chess_game/games/skills_option1.dart';
import 'package:chess_game/games/skills_option2.dart';
import 'package:chess_game/profile_page.dart';
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
import 'screen/resume_screen.dart';
import 'notification_page.dart';

const kWebRecaptchaSiteKey = "AIzaSyBYsklEXh8FvrcDuxX1c6GzwKz3SmSZuo4";
//'AIzaSyAlQloKdaZyZ07q653fAWogE1swGdohGzA';
List<CameraDescription> cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.instance.registerSingleton<GameLogic>(GameLogicImplementation(), signalsReady: true);
  // Initialize other dependencies
  cameras = await availableCameras();
  MobileAds.instance.initialize();

  final prefs = await SharedPreferences.getInstance();
  GetIt.instance.registerSingleton<SharedPreferences>(prefs);

  await NotificationService.initializeLocalNotifications();

  final webSocketManager = WebSocketManager();
  await webSocketManager.init('ws://93.127.206.44:3007');  // Ensure initialization here
  GetIt.instance.registerSingleton<WebSocketManager>(webSocketManager);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  ));

  Get.put(UserController());

  runApp(
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
        child: FutureBuilder(
          future: initPrefsAndSetupWebSocket(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Lead Chess',
                initialBinding: BindingsBuilder(() {
                  Get.put(CurrentUser());
                }),
                theme: ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.white,
                ),
                home: const Splashscreen(),
                routes: {
                  '/homescreen': (context) => HomeScreen(),
                  '/skillsOption1': (context) => SkillsOption1(),
                  '/skillsOption2': (context) => SkillsOption2(),
                  '/colorOption1': (context) => ColorOption1(),
                  '/colorOption2': (context) => ColorOption2(),
                  '/resume': (context) => ResumeScreen(),
                  '/localGame1': (context) {
                    final args = ModalRoute.of(context)!.settings.arguments;
                    final selectedTime = args is int ? args : 1;
                    return LocalGame1(selectedTime: selectedTime);
                  },
                  '/localGame2': (context) => const LocalGame2(),
                  '/game': (context) => const GameScreen(),
                },
              );
            } else {
              return const CircularProgressIndicator(); // Or any loading indicator
            }
          },
        ),
      ),
    );
  }

  Future<void> initPrefsAndSetupWebSocket() async {
    final prefs = GetIt.instance<SharedPreferences>();
    // Fetch session token from SharedPreferences
    String? sessionToken = prefs.getString('sessionToken');
    print('Session token in initPrefs: $sessionToken');

    // If session token is null, navigate to home screen where it might be fetched
    if (sessionToken == null) {
      await Future.delayed(Duration(seconds: 1)); // Optional delay
      Get.to(() => const ProfilePage()); // Navigate to HomeScreen
    } else {
      await _initializeWebSocketManager(sessionToken);
    }
  }

  Future<void> _initializeWebSocketManager(String sessionToken) async {
    final webSocketManager = GetIt.instance<WebSocketManager>();

    if (!webSocketManager.isInitialized) {
      const url = 'ws://93.127.206.44:3007';
      await webSocketManager.init(url);
    }

    if (sessionToken.isNotEmpty) {
      print('Sending user_info message with session token: $sessionToken');
      webSocketManager.send(json.encode({
        'type': 'test_message',
        'sessionToken': sessionToken,
      }));
    }
  }
}
