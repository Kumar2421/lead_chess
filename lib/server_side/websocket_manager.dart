import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  WebSocketManager._internal();

  factory WebSocketManager() {
    return _instance;
  }

  late WebSocketChannel _channel;
  late StreamController<String> _streamController;
  bool isInitialized = false;
  Function(String message)? onMessageReceived;

  Future<void> init(String url) async {
    if (!isInitialized) {
      try {
        print('Attempting to connect to WebSocket server at $url');
        _channel = IOWebSocketChannel.connect(url);
        _streamController = StreamController<String>.broadcast();
        isInitialized = true;
        print('WebSocket connection established.');

        _channel.stream.listen((message) {
          // Check if the message is a List<int> (binary data)
          if (message is List<int>) {
            // Decode binary data to a String
            String decodedMessage = utf8.decode(message);
            print('Decoded WebSocket message: $decodedMessage');
            _streamController.add(decodedMessage);
            if (onMessageReceived != null) {
              onMessageReceived!(decodedMessage);
            }
          } else if (message is String) {
            // Handle the case where the message is already a String
            print('Raw WebSocket message received: $message');
            _streamController.add(message);
            if (onMessageReceived != null) {
              onMessageReceived!(message);
            }
          } else {
            print('Unhandled WebSocket message type: ${message.runtimeType}');
          }
        }, onError: (error) {
          print('WebSocket error: $error');
        }, onDone: () {
          print('WebSocket connection closed');
        });
      } catch (e) {
        print('WebSocket connection error: $e');
      }
    } else {
      print('WebSocketManager is already initialized.');
    }
  }

  Stream<String> get stream => _streamController.stream;

  void send(String message) {
    if (isInitialized) {
      try {
        _channel.sink.add(message);
        print('Message sent: $message');
      } catch (e) {
        print('Error sending message: $e');
      }
    } else {
      print('WebSocketManager not initialized. Cannot send message.');
    }
  }

  void close() {
    _channel.sink.close();
    _streamController.close();
  }
}
