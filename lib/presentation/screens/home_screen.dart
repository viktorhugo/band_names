import 'dart:io';

import 'package:band_names/models/band_model.dart';
import 'package:band_names/providers/web_socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Bon Joi', votes: 2),
    Band(id: '3', name: 'Silent Heroes', votes: 20),
    Band(id: '3', name: 'Queen', votes: 7),
  ];

  @override
  Widget build(BuildContext context) {

    final WebSocketService webSocketService = Provider.of<WebSocketService>(context);
    final WebSocketServerStatus status = webSocketService.serverStatus;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 9,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                if ( status == WebSocketServerStatus.Connecting || status == WebSocketServerStatus.Reconnecting) 
                  Icon(Icons.autorenew_sharp, color: Colors.cyan[300], size: 30,),
                if ( status == WebSocketServerStatus.Online) 
                  Icon(Icons.check_circle_outline_rounded, color: Colors.green[300], size: 30,),
                if ( status == WebSocketServerStatus.Offline) 
                  Icon(Icons.offline_bolt_rounded, color: Colors.red[300], size: 30,),
              ],
            ) 
              
          )
          
        ],
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (BuildContext context, int index) => _banTile(bands[index])
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewBand(),
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _banTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: const EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: const Row(
          children: [
            Icon(Icons.delete, color: Colors.white, size: 30),
            SizedBox(width: 5),
            Text('Delete Band', style: TextStyle( color: Colors.white, fontSize: 20)),
          ],
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0,2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20),),
        onTap: () {
          print(band.name);
        },
      ),
      onDismissed: (DismissDirection direction) {
        // borrar inthe server
        print('Diraction $direction');
        print('Id ${band.id}');
      },
    );
  }

  addNewBand() {

    final textController = TextEditingController();
    if (Platform.isAndroid) {
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            title: const Text('New Band Name'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text),
                child: const Text('Add', style: TextStyle(fontSize: 22),),

              )
            ],
          );
        }
      );
    } else {
      showCupertinoDialog(
        context: context, 
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('New Band Name'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                child:  const Text('Dismiss', style: TextStyle(fontSize: 22),),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child:  const Text('Add', style: TextStyle(fontSize: 22),),
                onPressed: () => addBandToList(textController.text),
              )
            ],
          );
        }
      );
    }
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      // add band 
      bands.add(
        Band(id: (bands.length + 1).toString(), name: name, votes: 0)
      );
      setState(() {});
    }
    Navigator.pop(context);
  }

}