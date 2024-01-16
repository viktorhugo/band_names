import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


enum WebSocketServerStatus  {
  Online,
  Offline,
  Connecting
}

class WebSocketService with ChangeNotifier {

  WebSocketServerStatus _webSocketServerStatus = WebSocketServerStatus.Connecting;

  WebSocketService(){
    _initConfig();
  }

  void _initConfig() {
      print('_initConfig');
    
    // ws://127.0.0.1:8082
    IO.Socket socket = IO.io("ws://127.0.0.1:8082", <String, dynamic>{
      "transports": ["websocket"],
    });

    // IO.Socket socket = IO.io('http://127.0.0.1:3000',
    //   IO.OptionBuilder()
    //   .setTransports(['websocket']) // for Flutter or Dart VM
    //   .enableAutoConnect()// optional
    //   .build()
    // );

    socket.onConnect((_) {
      print('Connected to Web Socket Server');
      _webSocketServerStatus = WebSocketServerStatus.Online;
      socket.emit('msg', 'test');
    });

    

    // listen on disconnect server
    socket.onDisconnect((_) { 
      print('Disconnected to Web Socket Server');
      _webSocketServerStatus = WebSocketServerStatus.Offline;
    });

    // listen events from wss server
    socket.on('event', (data) => print(data));
    socket.on('fromServer', (_) => print(_));
  }

}