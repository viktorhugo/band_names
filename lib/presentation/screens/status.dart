import 'package:band_names/providers/web_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class StatusPage extends StatelessWidget {
  const StatusPage({super.key});


  @override
  Widget build(BuildContext context) {

    final WebSocketService webSocketService = Provider.of<WebSocketService>(context);

    return Scaffold(
      body: Center(
        child: Text(' ${webSocketService.serverStatus} '),
      ),
    );
  }
}