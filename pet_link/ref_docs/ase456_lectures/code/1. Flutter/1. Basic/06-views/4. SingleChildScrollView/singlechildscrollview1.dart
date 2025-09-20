import 'package:flutter/material.dart';

void main() => runApp(MyApp()); 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {return MaterialApp(home: Home());}
} 

class Home extends StatelessWidget {
  final items = List<int>.generate(30, (i) => i);

  Home({super.key});
  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView and ListBody allows us
    // to scroll the screen
    return SingleChildScrollView( 
      // ListBody displays Widgets in a List
      child: ListBody(
        children: items.map((i) => Text('Hello $i')).toList(),
      ),
    );
  }
}

