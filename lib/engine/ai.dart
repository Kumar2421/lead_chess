import 'package:stockfish/stockfish.dart'; 

class ChessAI {
  final stockfish = Stockfish(); 

  static const difficulties = {
    //'Kid': {'skillLevel': -7, 'depth': -0.5, 'nodes': -1},
    'Easy': {'skillLevel': 0, 'depth': 0, 'nodes': 0},
    'Normal': {'skillLevel': 5, 'depth': 1, 'nodes': 5},
    'Hard': {'skillLevel': 10, 'depth': 8, 'nodes': 20}, 
   // 'Unreal': {'skillLevel': 20, 'depth': 20, 'nodes': 10},
  }; 

  bool isReady() => stockfish.state.value == StockfishState.ready; 
  Future<String> compute(String fen, String difficulty, int timeMS) async {
    if (!isReady()) throw Exception("Stockfish not ready"); 
    if (difficulties[difficulty] == null) throw Exception("There is no such AI difficulty: $difficulty"); 
    final difficultyData = difficulties[difficulty]!; 
    stockfish.stdin = "ucinewgame"; 
    stockfish.stdin = "isready"; 
    stockfish.stdin = "setoption name Skill Level value ${difficultyData['skillLevel']}"; 
    stockfish.stdin = "setoption name Use NNUE value false"; 
    stockfish.stdin = "position fen $fen"; 
    stockfish.stdin = "go depth ${difficultyData['depth']} movetime $timeMS" 
          + (difficultyData['nodes'] != -1 ? "nodes ${difficultyData['nodes']}" : ""); 
    return stockfish.stdout.firstWhere((line) => line.startsWith("bestmove"))
          .then((line) => line.split(" ")[1]); 
  }
}