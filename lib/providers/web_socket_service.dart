import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


enum WebSocketServerStatus  {
  Online,
  Offline,
  Connecting
}

class WebSocketService with ChangeNotifier {

  WebSocketServerStatus _webSocketServerStatus = WebSocketServerStatus.Connecting;

  get serverStatus => _webSocketServerStatus;

  WebSocketService(){
    _initConfig();
  }

  void _initConfig() async {
      print('_initConfig');
      // in test Ipconfig IP
      final wsUrl = Uri.parse('ws://192.168.1.4:8082');
      final WebSocketChannel channel = WebSocketChannel.connect(wsUrl);

      try {
        await channel.ready;
        print('Web Socket Server Connected to $wsUrl');
        _webSocketServerStatus = WebSocketServerStatus.Online;
        notifyListeners();
      } on SocketException catch (e) {
        // Handle the exception.
        print('Error SocketException: ${e.message} - ( ${e.osError} )');
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
          
        },onError: (e){
          print(e); 
          // Future.delayed(Duration(seconds: 10)).then((value) {
          //   connectAndListen();
          // },);
        },
        onDone: (() {
          print('Error Web Socket Server DisConnected to $wsUrl');
          _webSocketServerStatus = WebSocketServerStatus.Offline;
          notifyListeners();
          // Future.delayed(Duration(seconds: 4)).then((value) {
          //   connectAndListen();
          // },);
        })
      );

      // If `ready` completes without an error then the channel is ready to
      // send data.
      channel.sink.add(
        jsonEncode(
          {
            "event": "create-band", 
            "data": {}
          },
        ),
      );
    

    // socket.onConnect((_) {
    //   print('Connected to Web Socket Server');
    //   _webSocketServerStatus = WebSocketServerStatus.Online;
    //   socket.emit('msg', 'test');
    // });

    

    // // listen on disconnect server
    // socket.onDisconnect((_) { 
    //   print('Disconnected to Web Socket Server');
    //   _webSocketServerStatus = WebSocketServerStatus.Offline;
    // });

    // // listen events from wss server
    // socket.on('event', (data) => print(data));
    // socket.on('fromServer', (_) => print(_));
  }

}