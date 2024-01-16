import 'package:band_names/config/router/app_router.dart';
import 'package:band_names/config/theme/app_theme.dart';
import 'package:band_names/providers/web_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WebSocketService()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        theme: AppTheme().getTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}