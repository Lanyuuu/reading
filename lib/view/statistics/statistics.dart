import 'package:flutter/material.dart';

class Statistics extends StatelessWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: const Center(
        child: Text('统计'),
      )
    );
  }
}