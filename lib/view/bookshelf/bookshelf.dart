import 'package:flutter/material.dart';

class Bookshelf extends StatelessWidget {
  const Bookshelf({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('书架')),
      body: const Center(
        child: Text('书架'),
      )
    );
  }
}