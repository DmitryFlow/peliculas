//

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:peliculas/providers/movies_provider.dart';
import 'screens/screens.dart';

void main() => runApp(const AppState());

class AppState extends StatelessWidget {

  const AppState({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // lazy: para que llame forzadamente y no cuanto necesite de provider.
        ChangeNotifierProvider(create: (_) => MoviesProvider(), lazy: false)
      ],child: const MyApp()
    );
  }
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: 'home',
      routes: {
        'home':     (_) => const HomeScreen(),
        'details':  (_) => const DetailsScreen()
      },
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(color: Colors.indigo)
      )
    );
  }
}