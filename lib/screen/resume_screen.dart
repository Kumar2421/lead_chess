import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:localstore/localstore.dart'; 
import 'dart:async';
import '../colors.dart';
import '../games/game_model.dart';
import 'package:get_it/get_it.dart'; 
import '../games/game_logic.dart';

final logic = GetIt.instance<GameLogic>(); 

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({ super.key });

  @override
  _ResumeScreenState createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final List<Game> _games = [];  
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    _subscription = Localstore.instance.collection('games').stream.listen((gameMap) {
      final game = Game.fromMap(gameMap); 
      if (!_games.contains(game)) {
        setState(() => _games.add(game)); 
      }
    }); 
    if (kIsWeb) Localstore.instance.collection('games').stream.asBroadcastStream();
    super.initState();
  }
  @override 
  void dispose() {
    _subscription?.cancel(); 
    super.dispose(); 
  }

  void _delete(int gameIndex) {
    _games[gameIndex].delete(); 
    setState(() => _games.removeAt(gameIndex)); 
  }

  void _openGame(int index) {
      logic.load(_games[index]); 
      _delete(index); 
      Navigator.pushNamed(context, "/localGame2");
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body:Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('assets/home.jpeg'), fit: BoxFit.cover,),
        ),
        child: Column(
          children: [
            SizedBox(height: 100,),
            _games.isEmpty ? const Center(child: Text("You have no unfinished games", textScaleFactor: 1.5))
                : Expanded(
                  child: ListView.builder(
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      final game = _games[index];
                      return ClipPath(
                      clipper: ParallelogramClipper(),
                        child: Card(
                          borderOnForeground: false,
                          child: ListTile(
                            tileColor: Colors.white,
                            title: Text(game.name),
                            onTap: () => _openGame(index),
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () => _openGame(index),
                            ),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _delete(index)
                            ),
                          ),
                        ),
                      );
                      },
                  ),
            ),
          ],
        ),
      )
    ); 
  } 
}


class ParallelogramClipper extends CustomClipper<Path> {
  final double borderSize;
  final Color borderColor;

  ParallelogramClipper({this.borderSize = 5.0, this.borderColor = color.blue3});

  @override
  Path getClip(Size size) {
    // Path path = Path();
    // path.moveTo(size.width * 0.1, 0); // Move to top left with an offset
    // path.lineTo(size.width, 0); // Line to top right
    // path.lineTo(size.width * 0.9, size.height); // Line to bottom right with an offset
    // path.lineTo(0, size.height); // Line to bottom left
    // path.close(); // Close the path
    // return path;

    final height = size.height;
    final width = size.width;

    // Path path = Path();
    // path.lineTo(0, height);
    // path.lineTo(width * 0.9, height);
    // path.lineTo(width, 0);
    // path.close();

    Path path = Path();
    path.lineTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width * 0.9, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

