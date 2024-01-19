import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


enum WebSocketServerStatus  {
  Online,
  Offline,
  Connecting,
  Reconnecting
}

class WebSocketService with ChangeNotifier {

  WebSocketServerStatus _webSocketServerStatus = WebSocketServerStatus.Connecting;

  late WebSocketChannel channel;

  get serverStatus => _webSocketServerStatus;

  WebSocketService() {
    // init start connection
    _startConnection();
  }

  void _startConnection() async {
    print('_initConfig');
    // in test Ipconfig IP
    final wsUrl = Uri.parse('ws://192.168.1.5:8082');
    channel = WebSocketChannel.connect(wsUrl);

    try {
      await channel.ready;
      print('Web Socket Server Connected to $wsUrl');
      _webSocketServerStatus = WebSocketServerStatus.Online;
      notifyListeners();
    } on SocketException catch (e) {
      // Handle the exception.
      print('Error SocketException: ${e.message} - ( ${e.osError} )');
      _handleLostConnection();
      return;
    } on WebSocketChannelException catch (e) {
      // Handle the exception.
      print('Error WebSocketChannelException: ${e.message} ');
      return;
    }

    channel.stream.listen((message) {
        print( jsonDecode(message) );

        // channel.sink.add('received!');
        // channel.sink.close(status.goingAway);
        
      },onError: (e) {
        print(e); 
        _handleLostConnection();
      },
      onDone: (() {
        print('Error Web Socket Server DisConnected to $wsUrl');
        _webSocketServerStatus = WebSocketServerStatus.Offline;
        notifyListeners();
        _handleLostConnection();
      })
    );
    
  }

  handleSendMessage(String event, data) {
    // send data.
    channel.sink.add(
      jsonEncode(
        {
          "event": "create-band", 
          "data": data
        },
      ),
    );
  }

  void _handleLostConnection() {
    _webSocketServerStatus = WebSocketServerStatus.Reconnecting;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _startConnection();
    });
  }

}