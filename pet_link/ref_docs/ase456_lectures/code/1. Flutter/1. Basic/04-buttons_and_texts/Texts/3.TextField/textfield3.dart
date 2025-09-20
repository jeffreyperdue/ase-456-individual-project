import 'package:flutter/material.dart';

void main() => runApp(MyApp()); 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {return const MaterialApp(home: TextFieldPage(title:'TextField'));}
} 

class TextFieldPage extends StatefulWidget {
  const TextFieldPage({super.key, required this.title});
  final String title;

  @override
  State<TextFieldPage> createState() => _TextFieldPageState();
}


class _TextFieldPageState extends State<TextFieldPage> {
  late String _string = 'Hello World';

  void _updateString(String newString) {
    setState(() {_string = newString;}); // Notify Dart UI to update screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TextField'),
      ),
      body: Column(
        children:[
          Text(_string),
          TextField(
            onSubmitted: (value) => _updateString(value),
          ),
        ]
      ),
    );
  }
}



