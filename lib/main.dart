import 'package:flutter/material.dart';

main() {() => runApp(const MyApp());}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Epub Reader',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Epub Reader'),
        ),
        body: const HomeContent(),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        BookItem('三体', '刘慈欣', 'https://img1.doubanio.com/view/subject/s/public/s2768378.jpg'),
        BookItem('寻找百忧解', '陈百忧', 'https://img2.doubanio.com/view/subject/s/public/s34415563.jpg'),
        BookItem('芯片战争', '[美]克里斯·米勒', 'https://img2.doubanio.com/view/subject/s/public/s34500182.jpg'),
      ],
    );
  }
}

class BookItem extends StatelessWidget {
  final String title;
  final String author;
  final String imgUrl;
  
  const BookItem(this.title,this.author,this.imgUrl,{super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey
          )
        )
      ),
      child: Column(
        children: [
          Text(title),
          Text('作者: $author'),
          const SizedBox(height: 10,),
          Image.network(imgUrl),
          const SizedBox(height: 10,),
        ],
      )
    );
  }
}