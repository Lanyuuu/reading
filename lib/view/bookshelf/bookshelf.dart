import 'dart:math';

import 'package:flutter/material.dart';

class Bookshelf extends StatefulWidget {
  const Bookshelf({Key? key}) : super(key: key);

  @override
  _BookshelfState createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        childAspectRatio: 0.7,
        crossAxisCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
        mainAxisSpacing: 20,
        physics: const BouncingScrollPhysics(),
        children: List.generate(22, (index) {
          return GestureDetector(
              onTap: () async {},
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // 阴影颜色
                            spreadRadius: 2, // 阴影扩散的范围
                            blurRadius: 5, // 阴影的模糊程度
                            offset: const Offset(0, 3), // 阴影的偏移量
                          ),
                        ],
                      ),
                      child: Image.network(
                        'https://picsum.photos/200/300?random=$index',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Text(
                      'Title TitleTitleTitle TitleTitleTitle',
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ));
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print('add book'),
        tooltip: 'Add Book',
        child: Icon(Icons.add),
      ),
    );
  }
}
