import 'package:flutter/material.dart';

void main() => runApp(MyApp()); 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StudentListView()
    );
  }
} 

// Simple ListView example
class StudentListView extends StatelessWidget {
  final List<String> students = [
    'Alice Johnson', 'Bob Smith', 'Carol Davis', 'David Wilson',
    // ... hundreds more students
  ];

  const StudentListView({super.key});

  @override
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student List')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(students[index]),
            subtitle: Text('Student ID: ${1000 + index}'),
          );
        },
      ),
    );
  }
}