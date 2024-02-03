import 'dart:convert';
import 'package:chess_game/server_side/websocket_manager.dart';
import 'package:chess_game/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'engine/choose_difficulty_screen.dart';
import 'engine/choose_color_screen.dart';
import 'engine/game_logic.dart';
import 'engine/game_screen.dart';
import 'engine/resume_screen.dart';
import 'engine/timer.dart';

void main() async {
  GetIt.instance.registerSingleton<GameLogic>(GameLogicImplementation(), signalsReady: true);

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  ));

  runApp(MyApp());
}

late WebSocketManager webSocketManager;
late SharedPreferences prefs; // SharedPreferences instance

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: FutureBuilder(
        // Use a FutureBuilder to wait for the async initialization
        future: initPrefs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Initialize WebSocketManager with the retrieved session token
            _initializeWebSocketManager();

            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.white,
              ),
              home: const Splashscreen(), // Assuming you have a Splashscreen widget
              routes: {
                '/difficulty': (context) => const ChooseDifficultyScreen(),
                '/color': (context) => const ChooseColorScreen(),
                '/resume': (context) => const ResumeScreen(),
                '/game': (context) => GameScreen(webSocketManager: GetIt.instance<WebSocketManager>()),
                "/clock": (context) => const ClockWidget(),
              },
            );
          } else {
            return CircularProgressIndicator(); // Or any loading indicator
          }
        },
      ),
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
      webSocketManager = WebSocketManager('ws://192.168.220.206:3005');
      webSocketManager.init('ws://192.168.220.206:3005');


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
  }}



