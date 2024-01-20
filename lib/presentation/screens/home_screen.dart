import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:band_names/models/band_model.dart';
import 'package:band_names/providers/web_socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Band> bands = [];

  @override
  void initState() {
    // final WebSocketService webSocketService = Provider.of<WebSocketService>(context);
    // implemetation
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    final WebSocketService webSocketService = Provider.of<WebSocketService>(context);
    final WebSocketServerStatus status = webSocketService.serverStatus;
    bands = webSocketService.bands;

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
                if ( status == WebSocketServerStatus.connecting || status == WebSocketServerStatus.reconnecting) 
                  Spin(
                    infinite: true,
                    child: const Icon(Icons.autorenew_sharp, color: Colors.purple, size: 31,)
                  ),
                if ( status == WebSocketServerStatus.online) 
                  BounceInRight(
                    duration: const Duration(milliseconds: 1000),
                    child: Icon(Icons.check_circle_rounded, color: Colors.blue[300], size: 31,)
                  ),
                if ( status == WebSocketServerStatus.offline) 
                  Icon(Icons.offline_bolt_rounded, color: Colors.red[300], size: 30,),
              ],
            ) 
              
          )
          
        ],
      ),
      body: Column(
        children: [

          (bands.isNotEmpty)
            ? _graph()
            : const Text('No hay bandas'),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) => _banTile(bands[index])
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewBand(),
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _banTile(Band band) {
    // listen en false por que no se va redibujar nada
    final WebSocketService webSocketService = Provider.of<WebSocketService>(context, listen: false);

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
          final data = { "id": band.id };
          webSocketService.handleSendMessage('add-vote-band', data);
        },
      ),
      onDismissed: (DismissDirection direction) {
        // borrar inthe server
        print('Diraction $direction');
        print('Id ${band.id}');
        final data = { "id": band.id };
        webSocketService.handleSendMessage('delete-band', data);
      },
    );
  }

  void addNewBand() {

    final textController = TextEditingController();
    if (Platform.isAndroid) {
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
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
        )
      );
    } else {
      showCupertinoDialog(
        context: context, 
        builder: (context) => CupertinoAlertDialog(
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
        )
      );
    }
  }

  void addBandToList(String name) {

    final WebSocketService webSocketService = Provider.of<WebSocketService>(context, listen: false);

    if (name.length > 1) {
      // add band 
      final data = { "name":  name};
      webSocketService.handleSendMessage('create-band', data);
    }
    Navigator.pop(context);
  }

  Widget _graph() {

    Map<String, double> dataMap = {};

    for (var band in bands) { 
      dataMap.putIfAbsent( band.name, () => band.votes.toDouble());
    }
    
    return Container(
      padding: const EdgeInsets.only(top: 20),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        // colorList: colorList,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          // legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );
    
  }
}
