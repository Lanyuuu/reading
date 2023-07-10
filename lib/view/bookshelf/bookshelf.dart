import 'package:flutter/material.dart';
import 'childComp/open_file.dart';

class Bookshelf extends StatefulWidget {
  const Bookshelf({Key? key}) : super(key: key);

  @override
  BookshelfState createState() => BookshelfState();
}

class BookshelfState extends State<Bookshelf> {
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
                    Image.network(
                        'https://picsum.photos/200/300?random=$index',
                        fit: BoxFit.contain,
                      ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: Text(
                        'TitleTitleTitleTitleTitleTitleTitle',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ));
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          pickFile(),
        },
        tooltip: 'Add Book',
        child: const Icon(Icons.add),
      ),
    );
  }
}
