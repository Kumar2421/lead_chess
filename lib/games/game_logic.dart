import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../server_side/websocket_manager.dart';
import '../user/current_user.dart';
import 'game_arguments.dart';
import 'ai.dart';
import 'game_model.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';


final logic = GetIt.instance<GameLogic>();
typedef Piece = chess_lib.Piece;
typedef PieceType = chess_lib.PieceType;
typedef PieceColor = chess_lib.Color;

class ChessTimer {
  late Duration initialTime;
  late Duration currentTime;
  late Timer? _timer; // Nullable Timer

  ChessTimer(this.initialTime) {
    reset();
    _timer = null; // Initialize as null
  }

  void reset() {
    currentTime = initialTime;
  }

  void start(Function onTimerTick, Function onTimerFinished) {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentTime.inSeconds > 0) {
        currentTime -= const Duration(seconds: 1);
        onTimerTick(); // Callback for each timer tick
      } else {
        timer.cancel();
        _timer = null; // Set the timer to null after finishing
        onTimerFinished(); // Callback when the timer finishes
      }
    });
  }

  void stop() {
    _timer?.cancel(); // Cancel the timer if it exists
    _timer = null; // Set the timer to null
  }
}

final player = AudioPlayer();

abstract class GameLogic extends ChangeNotifier {
  bool isSoundEnabled = true; // Default is sound enabled

  // Methods for controlling sound
  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
    // Save the sound mode preference
    saveSoundModePreference(isSoundEnabled);
    notifyListeners();
  }

  // Load sound mode preference from SharedPreferences
  void loadSoundModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true; // Default is true if preference is not found
    notifyListeners();
  }

  // Save sound mode preference to SharedPreferences
  void saveSoundModePreference(bool isSoundEnabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSoundEnabled', isSoundEnabled);
  }
  ChessTimer get player1Timer;
  ChessTimer get player2Timer;
  String? get selectedTile;
  List<String> get availableMoves;
  List<PieceType> get eatenBlack;
  List<PieceType> get eatenWhite;
  Map<String, String>? get previousMove; // 'from' and 'to' keys that point to positions on the board

  GameArguments args=GameArguments(asBlack: false, isMultiplayer: false);

  void updateTimers(Duration newTime);
  void maybeCallAI();
  String boardIndex(int rank, int file);
  void tapTile(String index);
  int getRelScore(PieceColor color);
  void clear();
  void start();
  Game save();
  void load(Game game);
  bool canUndo();
  bool canRedo();
  // void undo();
  // void redo();
  Piece? get(String index);
  String? squareColor(String index);
  PieceColor turn();
  bool gameOver();
  bool inCheckmate();
  bool inDraw();
  bool inThreefoldRepetition();
  bool insufficientMaterial();
  bool inStalemate();
  bool get isPromotion;
  void promote(Piece? selectedPiece);
  int piecesEaten(PieceColor color);
  PieceColor bestMoveColor();
  PieceColor determineWinner();
  void sendGameStateToServer();
  // int bestMoveFor(PieceColor color);
  // int piecesCapturedBy(PieceColor color);
}
//AudioCache audioCache = AudioCache();
class GameLogicImplementation extends GameLogic {

  late ChessTimer _player1Timer; // Rename here
  late ChessTimer _player2Timer; // Rename here
  GameLogicImplementation()
      : _player1Timer = ChessTimer(const Duration(minutes: 10)),
        _player2Timer = ChessTimer(const Duration(minutes: 10)) {//////////////////..here is change the time default time  is 1
    chessHistory.add(chess.fen);

  }
  final CurrentUser _currentUser = Get.put(CurrentUser());
  @override
  ChessTimer get player1Timer => _player1Timer; // Update here

  @override
  ChessTimer get player2Timer => _player2Timer; // Update here
  var chess = chess_lib.Chess();
  @override
  String? selectedTile;
  @override
  List<String> availableMoves = [];
  @override
  List<PieceType> eatenBlack = [];  // what black ate
  @override
  List<PieceType> eatenWhite = [];  // what white ate
  @override
  bool canUndo() => chessHistory.length > 1;
  @override
  bool canRedo() => chessRedoStack.isNotEmpty;
  // @override
  // void undo() {
  //   if (canUndo()) {
  //     chessRedoStack.add(chessHistory.removeLast());
  //     var lastState = chessHistory.last;
  //     chess.load(chessHistory.last);
  //    //  chess.load(lastState['fen']);
  //    //  eatenBlack = List<PieceType>.from(lastState['eatenBlack']);
  //    //  eatenWhite = List<PieceType>.from(lastState['eatenWhite']);
  //     notifyListeners();
  //     sendGameStateToServer();
  //   }
  // }
  //
  // @override
  // void redo() {
  //   if (canRedo()) {
  //     chess.load(chessRedoStack.removeLast());
  //     var nextState = chessRedoStack.removeLast();
  //     chessHistory.add(chess.fen);
  //  //    chess.load(nextState['fen']);
  //  //    eatenBlack = List<PieceType>.from(nextState['eatenBlack']);
  //  //    eatenWhite = List<PieceType>.from(nextState['eatenWhite']);
  //     chessHistory.add(nextState);
  //     notifyListeners();
  //     sendGameStateToServer();
  //   }
  // }

  @override
  int piecesEaten(PieceColor color) {
    var pieces = color == PieceColor.WHITE ? eatenWhite : eatenBlack;
    return pieces.isEmpty ? 0 : pieces.map((piece) => pieceScores[piece]!).fold(0, (a, b) => a + b);
  }

  @override
  PieceColor bestMoveColor() {
    int whiteScore = getRelScore(PieceColor.WHITE);
    int blackScore = getRelScore(PieceColor.BLACK);
    return whiteScore > blackScore ? PieceColor.WHITE : PieceColor.BLACK;
  }

  @override
  PieceColor determineWinner() {
    int whitePiecesEaten = piecesEaten(PieceColor.WHITE);
    int blackPiecesEaten = piecesEaten(PieceColor.BLACK);
    PieceColor bestMove = bestMoveColor();

    if (whitePiecesEaten > blackPiecesEaten) {
      return PieceColor.WHITE;
    } else if (blackPiecesEaten > whitePiecesEaten) {
      return PieceColor.BLACK;
    } else {
      return bestMove;
    }
  }

  @override
  // null means "this is a first move"
  // ignore: avoid_init_to_null
  Map<String, String>? previousMove = null;   // 'from' and 'to' keys that point to positions on the board

  @override
  bool get isPromotion => promotionMove != null;

  // null means "this move is not a promotion"
  // ignore: avoid_init_to_null
  var promotionMove = null;

  ChessAI ai = ChessAI();
  bool saveCurrentGame = false;

  List<String> chessHistory = [];
  List<String> chessRedoStack = [];
  // List<Map<String, dynamic>> chessHistory = [];
  // List<Map<String, dynamic>> chessRedoStack = [];


  static const boardFiles = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
  @override
  String boardIndex(int rank, int file) {
    return boardFiles[file] + (rank+1).toString();
  }

  static  Map<chess_lib.PieceType, int> pieceScores = {
    PieceType.PAWN : 1,
    PieceType.KNIGHT : 3,
    PieceType.BISHOP : 3,
    PieceType.ROOK : 5,
    PieceType.QUEEN : 8,
    PieceType.KING : 999,
  };

  int _getScore(PieceColor color) {
    return chess.board
        .where((piece) => piece != null && piece.color == color)
        .map((piece) => pieceScores[piece!.type]).fold(0, (p, c) => p + c!);
  }
  @override
  int getRelScore(PieceColor color) {
    PieceColor otherColor = color == PieceColor.WHITE ? PieceColor.BLACK : PieceColor.WHITE;
    var mainPlayerScore = _getScore(color);
    var secondPlayerScore = _getScore(otherColor);
    return math.max(mainPlayerScore, secondPlayerScore) - secondPlayerScore;
  }

  @override
  Piece? get(String index) => chess.get(index);
  @override
  String? squareColor(String index) => chess.square_color(index);
  @override
  PieceColor turn() => chess.turn;
  @override
  bool gameOver() => chess.game_over;
  @override
  bool inCheckmate() => chess.in_checkmate;
  @override
  bool inDraw() => chess.in_draw;
  @override
  bool inThreefoldRepetition() => chess.in_threefold_repetition;
  @override
  bool insufficientMaterial() => chess.insufficient_material;
  @override
  bool inStalemate() => chess.in_stalemate;

  @override
  void updateTimers(Duration newTime) {
    _player1Timer = ChessTimer(newTime);
    _player2Timer = ChessTimer(newTime);
    notifyListeners();
  }
  void _startTimerForCurrentPlayer() {
    if (turn() == PieceColor.WHITE) {
      _player1Timer.start(_onTimerTick, _onTimerFinished);
    } else {
      _player2Timer.start(_onTimerTick, _onTimerFinished);
    }
  }

  void _onTimerTick() {
    // Callback for each timer tick
    notifyListeners();
  }
  void _onTimerFinished() {
    // Callback when the timer finishes
    if (gameOver()) {
      // Game is over, show the end dialog
      notifyListeners();
    } else {
      switchTurns();
      _startTimerForCurrentPlayer();
      notifyListeners();
    }
  }
  void switchTurns() {
    if (turn() == PieceColor.WHITE) {
      _player1Timer.stop();
      _player2Timer.reset();
    } else {
      _player2Timer.stop();
      _player1Timer.reset();
    }
  }

  void _addEatenPiece(Piece eatenPiece) {
    if (eatenPiece.color == PieceColor.BLACK) {
      eatenWhite.add(eatenPiece.type);
    } else {
      eatenBlack.add(eatenPiece.type);
    }
  }

  static Future<void> buttonClickSound() async {
    String audioPath = "audio/click_sound.mp3";
    await player.play(AssetSource((audioPath)));
  }
  Future<void> playMoveSound() async {
    String audioPath = "audio/move_time_sound.mp3";
    await player.play(AssetSource((audioPath)));
  }
  void playPromotionMoveSound() async {
    String audioPath = "audio/promotion_sound.mp3";
    await player.play(AssetSource((audioPath)));
  }

  void playPieceToPieceCaptureSound() async {
    String audioPath = "audio/piece_to_piece_capture_sound.mp3";
    await player.play(AssetSource((audioPath)));
  }
  bool _move(move) {
    Piece? eatenPiece = chess.get(move['to']);
    bool isValid = chess.move(move);
    if (isValid) {
      //playSound();
      //if (eatenPiece != null) _addEatenPiece(eatenPiece);
      if (isSoundEnabled) {
        if (eatenPiece != null) {
          _addEatenPiece(eatenPiece);
          // Play sound for piece-to-piece capture
          playPieceToPieceCaptureSound();
        } else if (promotionMove != null) {
          //   // Play sound for promotion move
          playPromotionMoveSound();
        } else {
          // Play sound for regular piece move
          playMoveSound();
        }
      }
      if (chess.turn == PieceColor.WHITE) {
        _player2Timer.stop();
        _player1Timer.start(_onTimerTick, _onTimerFinished);
        // _player1Timer.stop();
        // _player2Timer.start(_onTimerTick, _onTimerFinished);
      } else {
        _player1Timer.stop();
        _player2Timer.start(_onTimerTick, _onTimerFinished);
        //_player2Timer.stop();
        // _player1Timer.start(_onTimerTick, _onTimerFinished);
      }
      maybeCallAI();
      previousMove = {'from': move['from'], 'to': move['to']};
      chessHistory.add(chess.fen); // Save the initial state to history
      //
      chessRedoStack.clear(); // Clear redo stack when a new move is made
      if (args.isMultiplayer) {
        sendGameStateToServer(); // Send the game state to the server only on a valid move after 1 second delay
      }
    }
    return isValid;
  }

  @override
  void maybeCallAI() async {
    if (!gameOver() && !args.isMultiplayer && !(args.asBlack == (chess.turn == PieceColor.BLACK))) {
      // Introduce a delay before AI calculates its move
      await Future.delayed(const Duration(seconds: 2)); // Adjust this to the desired AI delay

      // Wait until AI is ready to compute the move
      while (!ai.isReady()) {
        await Future.delayed(const Duration(milliseconds: 500)); // Check every 500ms if AI is ready
      }

      // Compute the move
      var move = await ai.compute(chess.fen, args.difficultyOfAI, 1000);

      // Make the AI move
      _move({
        'from': move[0] + move[1],
        'to': move[2] + move[3],
        'promotion': move.length == 5 ? move[4] : null
      });

      notifyListeners(); // Notify listeners after AI move
    }
  }


  @override
  void promote(Piece? selectedPiece) {
    if (selectedPiece != null) {
      promotionMove['promotion'] = selectedPiece.type.toString();
      _move(promotionMove);
    }
    promotionMove = null;
    notifyListeners();
    sendGameStateToServer();

  }

  void makeMove(String fromInd, String toInd) {
    final move = {'from': fromInd, 'to': toInd};
    bool isValid = _move(move);
    if (!isValid && chess.move({'from': fromInd, 'to': toInd, 'promotion': 'q'})) {
      chess.undo();
      promotionMove = move;
    } else if (promotionMove != null) {
      promotionMove = null;
      return;
    }
    sendGameStateToServer();
  }
  void select(String? index) {
    selectedTile = index;
    availableMoves = chess
        .moves({'square': index, 'verbose': true})
        .map((move) => move['to'].toString())
        .toList();
  }



  // @override
  // void notifyListeners() {
  //   print("notifyListeners() called");
  //   super.notifyListeners();
  // }

  Future<String?> getOpponentName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? opponent = prefs.getString('opponent');
    String? aiopponent = prefs.getString('starting_ai');
    print('$aiopponent: get here');
    print('$opponent: get here');
    return opponent;
  }
  @override
  void sendGameStateToServer() {
    SharedPreferences.getInstance().then((prefs) async {
      String? gameMode = prefs.getString('game_mode');
      String? aiopponent = prefs.getString('starting_ai');

      if (gameMode == 'online')  {
        final String? sessionToken = prefs.getString('sessionToken');
        final String? opponent = await getOpponentName();
        final String name = _currentUser.users.name;

        if (sessionToken == null || opponent == null) {
          print('Session token or opponent name is null. Cannot send game state.');
          return;
        }
        if (GetIt.instance.isRegistered<WebSocketManager>()) {
          webSocketManager = GetIt.instance<WebSocketManager>();
        }
        if (webSocketManager.isInitialized) {
          final gameState = {
            'fen': chess.fen,
            'history': chessHistory,
            'redoStack': chessRedoStack,
            'eatenWhite': eatenWhite.map((e) => e.toString()).toList(),
            'eatenBlack': eatenBlack.map((e) => e.toString()).toList(),
            'previousMove': previousMove,
            'promotionMove': promotionMove,
          };

          final message = {
            'type': 'game_state',
            'sessionToken': sessionToken,
            'username': name,
            'player1': name,
            'player2': opponent,
            'game_state': gameState,
          };

          final jsonString = json.encode(message);
          webSocketManager.send(jsonString);
          print('Sent game state update: $message');
        } else {
          print('WebSocketManager is not initialized. Cannot send game state.');
        }

        // Listening for incoming messages from the server
        webSocketManager.stream.listen((message) {
          print('Message received: $message');
          final decodedMessage = jsonDecode(message);
          if (decodedMessage['type'] == 'game_state') {
            handleReceivedGameState(decodedMessage['game_state']);
          }
        }, onError: (error) {
          print('Error receiving message: $error');
        }, onDone: () {
          print('WebSocket connection closed.');
        });
      }
    });
  }

  //
  // void sendDelayedGameStateToServer() {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     sendGameStateToServer();
  //   });
  // }

  void handleReceivedGameState(Map<String, dynamic> gameState) {
    final String fen = gameState['fen'] as String;

    final List<String>? history = gameState['history'] != null ? List<String>.from(gameState['history'] as List<dynamic>) : null;
    final List<String>? redoStack = gameState['redoStack'] != null ? List<String>.from(gameState['redoStack'] as List<dynamic>) : null;
    final List<String>? eatenWhite = gameState['eatenWhite'] != null ? List<String>.from(gameState['eatenWhite'] as List<dynamic>) : null;
    final List<String>? eatenBlack = gameState['eatenBlack'] != null ? List<String>.from(gameState['eatenBlack'] as List<dynamic>) : null;
    final Map<String, String>? previousMove = gameState['previousMove'] != null ? Map<String, String>.from(gameState['previousMove'] as Map<dynamic, dynamic>) : null;
    final Map<String, dynamic>? promotionMove = gameState['promotionMove'] != null ? Map<String, dynamic>.from(gameState['promotionMove'] as Map<dynamic, dynamic>) : null;

    // Update local game state
    chess.load(fen);
    if (history != null) chessHistory = history;
    if (redoStack != null) chessRedoStack = redoStack;
    if (eatenWhite != null) this.eatenWhite = eatenWhite.map((e) => pieceTypeFromJson(e)).toList();
    if (eatenBlack != null) this.eatenBlack = eatenBlack.map((e) => pieceTypeFromJson(e)).toList();
    this.previousMove = previousMove;
    this.promotionMove = promotionMove;

    notifyListeners();
    _startTimerForCurrentPlayer();

  }

  bool isAnyTimerFinished() {
    return _player1Timer.currentTime.inSeconds == 0 || _player2Timer.currentTime.inSeconds == 0;
  }

  @override
  void tapTile(String index) {
    SharedPreferences.getInstance().then((prefs) {
      String? aiopponent = prefs.getString('starting_ai');
      String? gameMode = prefs.getString('game_mode');
      //print('Game mode: $gameMode');
     // if (aiopponent == null) {
        if (gameMode == 'online') {
          // Online mode logic

          if (gameOver()) {
            print('Game over. No moves allowed.');
            return;
          }

          if (isAnyTimerFinished()) {
            print('Timer finished. Cannot select any pieces.');
            return;
          }

          // Validate if it's the player's turn
          if ((args.asBlack && turn() != PieceColor.BLACK) ||
              (!args.asBlack && turn() != PieceColor.WHITE)) {
            print('Not player\'s turn. Current turn: ${turn()}');
            return;
          }

          // Start the timer when a piece is clicked

          if (index == selectedTile) {
            print('Deselecting the piece at $index');
            select(null);
          } else if (selectedTile != null) {
            print('Selected tile is $selectedTile, target tile is $index');

            if (chess.get(index)?.color == chess.turn) {
              print('Target tile has a piece of the same color. Selecting piece at $index.');
              select(index);
            } else {
              print('Making a move from $selectedTile to $index');
              makeMove(selectedTile!, index);
              //_startTimerForCurrentPlayer();
              print('Timer started for the current player');
              select(null); // Deselect after move
            }
          } else if (chess.get(index)?.color == chess.turn) {
            print('Selecting piece at $index');
            select(index);
          } else {
            print('No valid piece at $index to select');
            return;
          }

          notifyListeners();
        }
      //}
      else {
        // Offline mode logic (including AI)
        print('$gameMode: Offline mode logic');

        if (gameOver()) {
          print('Game over. Cannot select any pieces.');
          return;
        }

        if (isAnyTimerFinished()) {
          print('Timer finished. Cannot select any pieces.');
          return;
        }

        // If it's AI's turn in offline mode, ensure AI can make a move
        if (!args.isMultiplayer && args.asBlack == (turn() == PieceColor.WHITE)) {
          print('Not player\'s turn. Current turn: ${turn()}');
          maybeCallAI();  // Call the AI for its turn
          return;
        }

        // Start the timer when a piece is clicked
        _startTimerForCurrentPlayer();
        print('Timer started for the current player');

        if (index == selectedTile) {
          print('Deselecting the piece at $index');
          select(null);
        } else if (selectedTile != null) {
          print('Selected tile is $selectedTile, target tile is $index');

          if (chess.get(index)?.color == chess.turn) {
            print('Target tile has a piece of the same color. Selecting piece at $index.');
            select(index);
          } else {
            print('Making a move from $selectedTile to $index');
            makeMove(selectedTile!, index);
            select(null); // Deselect after move
          }
        } else if (chess.get(index)?.color == chess.turn) {
          print('Selecting piece at $index');
          select(index);
        } else {
          print('No valid piece at $index to select');
          return;
        }

        notifyListeners();  // Notify listeners after processing
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
    // widget.webSocketManager.close();
    //matchmakingTimer?.cancel();
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('opponent');
      print('Opponent removed from SharedPreferences');
      prefs.remove('starting_ai');
      print('ai removed from SharedPreferences');
      prefs.remove('selected_color');
      print('selected_color removed from SharedPreferences');
      prefs.remove('game_mode');
      print('game_mode removed from SharedPreferences');


    });// Cancel the matchmaking timer
    //notifyListeners();
  }

  @override
  void clear() {
    chess.reset();
    selectedTile = null;
    availableMoves = [];
    eatenBlack = [];
    eatenWhite = [];
    promotionMove = null;
    previousMove = null;
    notifyListeners();
  }
  @override
  void start() {
    chess.reset();
    chessHistory.clear();

    chessRedoStack.clear();
    _player1Timer.reset();
    _player2Timer.reset();
    // _startTimerForCurrentPlayer();
 //   maybeCallAI();
    if (chess.turn != (args.asBlack ? PieceColor.BLACK : PieceColor.WHITE)) {
      maybeCallAI(); // Only call AI if it's their turn
    }

    notifyListeners();
    sendGameStateToServer();
  }
  @override
  Game save() {
    String name = DateTime.now().toString().substring(0, 16) +
        (args.isMultiplayer ? " LocalGame" : " vs ${args.difficultyOfAI}");
    final id = Localstore.instance.collection("games").doc().id;
    Game game = Game(
      id: id,
      name: name,
      fen: chess.fen,
      args: args,
      eatenBlack: eatenBlack,
      eatenWhite: eatenWhite,
    );
    game.save();
    return game;
  }

  @override
  void load(Game game) {
    clear();
    chess = chess_lib.Chess.fromFEN(game.fen);
    args = game.args;
    eatenBlack = game.eatenBlack;
    eatenBlack = game.eatenWhite;
    chessHistory.add(chess.fen); // Save the initial state to history

    notifyListeners();
    maybeCallAI();
  }
}
void main() {
  // Initialize your game logic
  GameLogicImplementation logic = GameLogicImplementation();
  logic.start(); // This will send the initial game state to the server
  // Other initialization logic
}
