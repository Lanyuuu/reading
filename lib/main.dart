import 'package:flutter/material.dart';
import 'components/tabbar.dart';
import "view/bookshelf/bookshelf.dart";
// import "view/profile/profile.dart";
// import "view/recommend/recommend.dart";
// import "view/statistics/statistics.dart";

void main() { 
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyStackPage(),
    );
  }
}

class MyStackPage extends StatefulWidget {
  const MyStackPage({Key? key}) : super(key: key);

  @override
  MyStackPageState createState() => MyStackPageState();
}

class MyStackPageState extends State<MyStackPage> {
  int _currentIndex = 0;
  callBack(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: TableBar(callBack),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Bookshelf(),
          // Recommend(),
          // Statistics(),
          // Profile(),
        ],
      ),
    );
  }
}