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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(14.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  const Expanded(child: SearchBox()),
                  IconButton(
                    icon: const Icon(Icons.add),
                    splashRadius: 20.0,
                    onPressed: () {
                      // TODO: 添加本地 epub 书籍的逻辑
                    },
                  ),
                ],
              ),
            ),
          )),
        body: const InfiniteListPage(),
      ),
    );
  }
}
