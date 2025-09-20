import 'package:flutter/material.dart';

// sizedbox can give size properties to any widgets without size related property 

void main() => runApp(MyApp()); 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {return MaterialApp(home: SizedBoxPage());}
} 

class SizedBoxPage extends StatelessWidget {
  const SizedBoxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SizedBox'),
      ),
      body: SizedBox(
        width: 100,
        height: 100,
        child: Container(
          color: Colors.red,
        ),
      ),
    );
  }
}
