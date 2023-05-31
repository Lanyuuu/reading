import 'package:flutter/material.dart';
import 'components/seach.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: const Center(
        child: SearchBox(),
      ),
    );
  }
}
