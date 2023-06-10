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
        BookItem('三体', '刘慈欣', 'https://img3.doubanio.com/view/subject/l/public/s2768378.jpg'),
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
    return Column(
      children: [
        Text(title),
        Text('作者: $author'),
        Image.network(imgUrl),
      ],
    );
  }
}