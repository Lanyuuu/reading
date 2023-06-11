import 'package:flutter/material.dart';
import 'components/table_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyStackPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyStackPage extends StatefulWidget {
  const MyStackPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyStackPageState createState() => MyStackPageState();
}

class MyStackPageState extends State<MyStackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: const TableBar()
    );
  }
}