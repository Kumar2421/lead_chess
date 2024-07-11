import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  late WebSocketChannel _channel;
  late StreamController<String> _streamController;
  bool isInitialized = false;

  WebSocketManager(String url) {
    init(url);
  }

  Future<void> init(String url) async {
    if (!isInitialized) {
      try {
        _channel = IOWebSocketChannel.connect(url);
        _streamController = StreamController<String>.broadcast();

        isInitialized = true;
      } catch (e) {
        print('WebSocket connection error: $e');
        // Handle connection error here, if needed
      }
    }
  }

  Stream<String> get stream => _streamController.stream;

  void send(String message) {
    if (isInitialized) {
      _channel.sink.add(message);
    } else {
      print('WebSocketManager not initialized. Cannot send message.');
    }
  }

  void close() {
    _channel.sink.close();
    _streamController.close();
  }
}
