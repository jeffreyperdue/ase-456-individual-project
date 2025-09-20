import 'package:flutter/material.dart';

// Widget with card shape

void main() => runApp(MyApp()); 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {return MaterialApp(home: CardPage());}
} 

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card'),
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4.0, // shadow depth
          child: SizedBox(
            width: 200, height: 200,
            child: Center(child: Text("Hello")),
          ),
        ),
      ),
    );
  }
}

