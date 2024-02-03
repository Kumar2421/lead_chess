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
      _channel = IOWebSocketChannel.connect("ws://192.168.220.206:3005");
      _streamController = StreamController<String>.broadcast();

      // Check if the stream is not being listened to before setting up the listener
      if (!_streamController.hasListener) {
        _channel.stream.listen(
              (dynamic message) {
            if (message is String) {
              _streamController.add(message);
            }
          },
          onDone: () {
            _streamController.close(); // Close the stream when the WebSocket is closed
          },
          onError: (error) {
            print('WebSocket error: $error');
          },
          cancelOnError: true,
        );
      }

      isInitialized = true;
    }
  }

  Stream<String> get stream => _streamController.stream;

  void send(String message) {
    _channel.sink.add(message);
  }

  void close() {
    _channel.sink.close();
    _streamController.close();
  }
}
