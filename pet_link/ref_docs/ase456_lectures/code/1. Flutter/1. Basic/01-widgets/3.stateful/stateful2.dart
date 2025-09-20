import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home:MyApp())); 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MyStateful();
  }
}

class MyStateful extends StatefulWidget {
  const MyStateful({super.key});

  @override
  State<MyStateful> createState() => _MyState();
}  

class _MyState extends State<MyStateful> {
  final String _str = "Hello";
  @override
  Widget build(BuildContext context) {
    return Text(_str);
  }
}
