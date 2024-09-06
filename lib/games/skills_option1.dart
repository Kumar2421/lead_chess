
import 'package:button_animations/button_animations.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import '../buttons/back_button.dart';
import 'game_logic.dart';
final logic = GetIt.instance<GameLogic>();

class SkillsOption1 extends StatelessWidget{
  const SkillsOption1({super.key});
 @override
  Widget build(BuildContext context){
   const difficulties = [
     "Easy", "Normal", "Hard",
   ];
   double screenHeight = MediaQuery.of(context).size.height;
   double screenWidth = MediaQuery.of(context).size.width;
   return Scaffold(
       body: Center(
         child: Container(
           height: screenHeight/1,
           width: screenWidth/1,
           decoration: const BoxDecoration(
               gradient: LinearGradient(
                 colors: [color.navy,Colors.black],
                 begin: Alignment.topRight,
                 end: Alignment.bottomRight,
                 // stops: [0.0,1.0],
                 // tileMode: TileMode.repeated,
               )
           ),
           child: Column(
               children: [
                 SizedBox(height: screenHeight/20,),
                 //ArrowBackButton(color: Colors.white,),
                 SizedBox(height: screenHeight/20,),
                 for (final difficulty in difficulties)
                   Column(
                     children: [
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
                           //AudioHelper.buttonClickSound();
                           logic.args.difficultyOfAI = difficulty;
                           Navigator.pushNamed(context, '/colorOption1');
                         },
                         child: Text(difficulty, textScaleFactor: 1.5,style: const TextStyle(color: Colors.white),),
                       ),
                       const SizedBox(height: 8),
                     ],
                   ),
               ]
           ),
         ),
       )
   );
 }
}



//
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:button_animations/button_animations.dart';
// import 'package:flutter/material.dart';
// import 'package:chess_game/colors.dart';
// import 'package:gap/gap.dart';
// import 'package:get_it/get_it.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../buttons/back_button.dart';
// import 'game_logic.dart';
//
// final logic = GetIt.instance<GameLogic>();
//
// class SkillsOption1 extends StatefulWidget {
//   const SkillsOption1({super.key});
//
//   @override
//   _SkillsOption1State createState() => _SkillsOption1State();
// }
//
// class _SkillsOption1State extends State<SkillsOption1> {
//   late List<WebSocketChannel> _channels;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeWebSocket();
//   }
//
//   void initializeWebSocket() {
//     final websocketUrls = ['ws://192.168.1.29:3004']; // Update with your WebSocket URL
//
//     _channels = websocketUrls.map((url) => IOWebSocketChannel.connect(url)).toList();
//
//     for (var channel in _channels) {
//       channel.stream.listen(
//             (message) {
//           String decodedMessage;
//
//           if (message is Uint8List) {
//             decodedMessage = utf8.decode(message);
//           } else if (message is String) {
//             decodedMessage = message;
//           } else {
//             print('Unsupported WebSocket message type: ${message.runtimeType}');
//             return;
//           }
//
//           print('Received WebSocket message: $decodedMessage');
//           handleWebSocketMessage(decodedMessage);
//         },
//         onError: (error) {
//           print('WebSocket error: $error');
//         },
//         onDone: () {
//           print('WebSocket stream has been closed.');
//         },
//       );
//     }
//   }
//
//
//   Future<void> handleWebSocketMessage(String message) async {
//     final decodedMessage = json.decode(message);
//     print('Received WebSocket message: $decodedMessage');
//     switch (decodedMessage['type']) {
//       case 'starting_ai':
//         handleAIStart();
//         break;
//       default:
//         print('Unknown WebSocket message type: ${decodedMessage['type']}');
//     }
//   }
//
//   void handleAIStart() {
//     // Automatically trigger "Normal" mode when "starting_ai" is received
//     setState(() {
//       logic.args.difficultyOfAI = "Normal";
//     });
//     Navigator.pushNamed(context, '/colorOption1');
//   }
//
//   @override
//   void dispose() {
//     for (var channel in _channels) {
//       channel.sink.close();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const difficulties = [
//       "Easy", "Normal", "Hard",
//     ];
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: Center(
//         child: Container(
//           height: screenHeight,
//           width: screenWidth,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [color.navy, Colors.black],
//               begin: Alignment.topRight,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Column(
//             children: [
//               SizedBox(height: screenHeight / 20),
//               const ArrowBackButton(color: Colors.white),
//               SizedBox(height: screenHeight / 20),
//               for (final difficulty in difficulties)
//                 Column(
//                   children: [
//                     AnimatedButton(
//                       blurRadius: 10,
//                       height: screenHeight / 20,
//                       width: screenWidth / 2.5,
//                       shadowColor: color.blue3,
//                       color: color.navy,
//                       onTap: () {
//                         AudioHelper.buttonClickSound();
//                         logic.args.difficultyOfAI = difficulty;
//                         Navigator.pushNamed(context, '/colorOption1');
//                       },
//                       child: Text(
//                         difficulty,
//                         textScaleFactor: 1.5,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
