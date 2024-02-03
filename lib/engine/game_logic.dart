import 'dart:async';
import 'game_arguments.dart';
import 'ai.dart';
import 'game_model.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'dart:math' as math;

typedef Piece = chess_lib.Piece;
typedef PieceType = chess_lib.PieceType;
typedef PieceColor = chess_lib.Color;

abstract class GameLogic extends ChangeNotifier {

  //BuildContext context; // Add this line
  //GameLogic(this.context); // Add this constructor

  String? get selectedTile;
  List<String> get availableMoves;
  List<PieceType> get eatenBlack;
  List<PieceType> get eatenWhite;
  Map<String, String>? get previousMove; // 'from' and 'to' keys that point to positions on the board
  Timer? player1Timer;
  Timer? player2Timer;
  int player1TimeInSeconds = 0;
  int player2TimeInSeconds = 0;
  bool isTimerRunning = false;
  bool _isMainPlayerTurn = true; // Track whose turn it is
  int _currentTimer = 0; // 0 for player 1, 1 for player 2


  GameArguments args=GameArguments(asBlack: false, isMultiplayer: false);


  String boardIndex(int rank, int file);
  void tapTile(String index);
  int getRelScore(PieceColor color);
  void clear();
  void start();
  Game save();
  void load(Game game);
  bool canUndo();
  bool canRedo();
  void undo();
  void redo();
  void startTimer();
  void stopTimer();
  void switchTurns();
  void updateTimers();
  bool isTimeUp();
  String getPlayer1Time();
  String getPlayer2Time();
  void setGameTimer(int seconds);
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
}

class GameLogicImplementation extends GameLogic {

  GameLogicImplementation()
    //  (BuildContext context) : super(context)
  {
    chessHistory.add(chess.fen);
  }
// Add this constructor

  var chess = chess_lib.Chess();
  @override
  String? selectedTile;
  @override
  List<String> availableMoves = [];
  @override
  List<PieceType> eatenBlack = [];  // what black ate
  @override
  List<PieceType> eatenWhite = [];  // what white ate
 // List<Map<String, String>?> movesHistory = [];
  @override
  bool canUndo() => chessHistory.length > 1;
  @override
  bool canRedo() => chessRedoStack.isNotEmpty;
  PieceColor _currentPlayer = PieceColor.WHITE; // Assume WHITE starts first
  @override
  void startTimer() {
    if (isTimerRunning) return;

    player1Timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentTimer == 0) {
        if (player1TimeInSeconds > 0) {
          player1TimeInSeconds--;
        } else {
          endGame(PieceColor.BLACK); // Player 2 wins on timeout
        }
      } else {
        if (player2TimeInSeconds > 0) {
          player2TimeInSeconds--;
        } else {
          endGame(PieceColor.WHITE); // Player 1 wins on timeout
        }
      }
      notifyListeners();
    });

    isTimerRunning = true;
  }

  @override
  void switchTurns() {
    _currentTimer = (_currentTimer + 1) % 2; // Switch turns between 0 and 1
    if (isTimerRunning) {
      stopTimer();
      startTimer();
    }
  }
  @override
  void stopTimer() {
    if (turn() == PieceColor.WHITE) {
      player1Timer?.cancel();
    } else {
      player2Timer?.cancel();
    }
    isTimerRunning = false;
  }

  void endGame(PieceColor winner) {
    endGame(winner);
    stopTimer();
  }
  @override
  void updateTimers() {
    if (_currentTimer == 0) {
      player1TimeInSeconds--;
    } else {
      player2TimeInSeconds--;
    }
    notifyListeners();
  }

  bool isTimeUp() {
    return player1TimeInSeconds <= 0 || player2TimeInSeconds <= 0;
  }
  //
  // void endGame(PieceColor winner) {
  //   stopTimer();
  //   showDialog(
  //     context: context, // Make sure 'context' is available
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Game Over"),
  //         content: Text("Player ${winner == PieceColor.WHITE ? '2' : '1'} wins!"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text("OK"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

    // Determine the winner and show a dialog (add your logic here)

    // Switch to the next player
  //   _currentPlayer = (_currentPlayer == PieceColor.WHITE)
  //       ? PieceColor.BLACK
  //       : PieceColor.WHITE;
  //
  //   // Restart the timer for the next player
  //   startTimer();
  // }
  // void stopTimer() {
  //   if (turn() == PieceColor.WHITE) {
  //     player1Timer?.cancel();
  //   } else {
  //     player2Timer?.cancel();
  //   }
  //   isTimerRunning = false;
  //
  //   // Switch to the next player
  //   _currentPlayer = (_currentPlayer == PieceColor.WHITE)
  //       ? PieceColor.BLACK
  //       : PieceColor.WHITE;
  // }
  //

  String getPlayer1Time() {
    int minutes = player1TimeInSeconds ~/ 60;
    int seconds = player1TimeInSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(1, '0')}';
  }

  String getPlayer2Time() {
    int minutes = player2TimeInSeconds ~/ 60;
    int seconds = player2TimeInSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(1, '0')}';
  }

  void setGameTimer(int seconds) {
    player1TimeInSeconds = seconds;
    player2TimeInSeconds = seconds;
    notifyListeners();
  }
  void undo() {
    if (canUndo()) {
      chessRedoStack.add(chessHistory.removeLast());
      chess.load(chessHistory.last);
      notifyListeners();
      // movesHistory.add(previousMove);
      // previousMove = null; // Disable further moves during undo
    }
  }

  void redo() {
    if (canRedo()) {
      chess.load(chessRedoStack.removeLast());
      chessHistory.add(chess.fen);
      notifyListeners();
     // previousMove = movesHistory.isNotEmpty ? movesHistory.removeLast() : null;
    }
  }
  // List<Map<String, String>?> getMovesHistory() {
  //   return List.from(movesHistory);
  // }
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

  void _addEatenPiece(Piece eatenPiece) {
      if (eatenPiece.color == PieceColor.BLACK) {
        eatenWhite.add(eatenPiece.type);
      } else {
        eatenBlack.add(eatenPiece.type);
      }
  }

  bool _move(move) {
    Piece? eatenPiece = chess.get(move['to']);
    bool isValid = chess.move(move);
    if (isValid) {
      if (eatenPiece != null) _addEatenPiece(eatenPiece);
      maybeCallAI();
      previousMove = {'from': move['from'], 'to': move['to']};
      chessHistory.add(chess.fen); // Save the board state to history
      chessRedoStack.clear(); // Clear redo stack when a new move is made
    }
    return isValid;
  }
  // bool _move(move) {
  //   Piece? eatenPiece = chess.get(move['to']);
  //   bool isValid = chess.move(move);
  //   if (isValid) {
  //     if (eatenPiece != null) _addEatenPiece(eatenPiece);
  //     maybeCallAI();
  //     previousMove = {'from': move['from'], 'to': move['to']};
  //   }
  //   return isValid;
  // }

  void maybeCallAI() async {
    if (!gameOver() && !args.isMultiplayer && !(args.asBlack == (chess.turn == PieceColor.BLACK))) {
      while (!ai.isReady()) {
        await Future.delayed(const Duration(seconds: 1));
      }
      var move = await ai.compute(chess.fen, args.difficultyOfAI, 1000);
      _move({'from': move[0]+move[1],
             'to': move[2]+move[3],
             'promotion': move.length == 5 ? move[4] : null});
    notifyListeners();
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
  }

  void makeMove(String fromInd, String toInd) {
    final move = {'from': fromInd, 'to': toInd};
    bool isValid = _move(move);
    if (!isValid &&
        chess.move({'from': fromInd, 'to': toInd, 'promotion': 'q'})) {
      chess.undo();
      promotionMove = move;
    } else if (promotionMove != null) {
      promotionMove = null;
    }
  }

  void select(String? index) {
    selectedTile = index;
    availableMoves = chess
        .moves({'square': index, 'verbose': true})
        .map((move) => move['to'].toString())
        .toList();
  }

  @override
  void tapTile(String index) {
    if (!args.isMultiplayer && args.asBlack == (turn() == PieceColor.WHITE)) {
      return;
    }

    if (index == selectedTile) {
      select(null);
    } else if (selectedTile != null) {
      if (chess.get(index)?.color == chess.turn) {
        select(index);
      } else {
        makeMove(selectedTile!, index);
        select(null);
      }
    } else if (chess.get(index)?.color == chess.turn) {
      select(index);
    } else {
      return;
    }
    notifyListeners();
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
    chessHistory.add(chess.fen);
    chessRedoStack.clear();
    maybeCallAI();
    notifyListeners();
  }
  @override
  Game save() {
    if (saveCurrentGame) {
      String name = DateTime.now().toString().substring(0, 16) +
          (args.isMultiplayer ? " Multiplayer" : " vs ${args.difficultyOfAI}");
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
      saveCurrentGame = false; // Reset the flag after saving
      chessHistory.clear(); // Clear the history after saving
      chessHistory.add(chess.fen); // Save the initial state to history
      chessRedoStack.clear(); // Clear redo stack after saving
      return game;
    }
    return Game(id: "", name: "", fen: "", args: GameArguments(), eatenBlack: [], eatenWhite: []);
  }

  // Game save() {
  //   String name = DateTime.now().toString().substring(0, 16) +
  //                (args.isMultiplayer ? " Multiplayer" : " vs ${args.difficultyOfAI}");
  //   final id = Localstore.instance.collection("games").doc().id;
  //   Game game = Game(
  //     id: id,
  //     name: name,
  //     fen: chess.fen,
  //     args: args,
  //     eatenBlack: eatenBlack,
  //     eatenWhite: eatenWhite,
  //   );
  //   game.save();
  //   return game;
  // }
  @override
  void load(Game game) {
    clear();
    chess = chess_lib.Chess.fromFEN(game.fen);
    args = game.args;
    eatenBlack = game.eatenBlack;
    eatenBlack = game.eatenWhite;
    notifyListeners();
    maybeCallAI();
  }
}