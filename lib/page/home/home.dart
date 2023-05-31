import 'package:flutter/material.dart';
import 'components/seach.dart';
import 'components/infinite_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello, World!',
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(15.0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: SearchBox(),
              ),
            )),
        body: InfiniteListPage(),
      ),
    );
  }
}
