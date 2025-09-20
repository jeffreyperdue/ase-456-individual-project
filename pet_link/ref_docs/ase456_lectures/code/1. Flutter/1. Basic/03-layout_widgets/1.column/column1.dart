import 'package:flutter/material.dart';

void main() => runApp(MyApp()); 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {return MaterialApp(home: Home());}
} 

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
          Text("Hello"),
          Text("Flutter"),
      ],
    );
  }
}

