import 'package:flutter/material.dart';
import 'childComp/open_file.dart';
import '/store/book_manager.dart';
import 'dart:io';

class Bookshelf extends StatefulWidget {
  const Bookshelf({Key? key}) : super(key: key);

  @override
  BookshelfState createState() => BookshelfState();
}

class BookshelfState extends State<Bookshelf> {
  List books = [];
  // 获取数据库的书本
  Future<void> getBooks() async {
    List fetchedBooks = await DatabaseManager.getAllBooks();
    setState(() {
      books = fetchedBooks;
    });
  }

  @override
  void initState() {
    super.initState();
    getBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        childAspectRatio: 0.7,
        crossAxisCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
        mainAxisSpacing: 20,
        physics: const BouncingScrollPhysics(),
        children: List.generate(books.length, (index) {
          return GestureDetector(
              onTap: () async {
                // await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => OpenFile(
                //       filePath: books[index].filePath,
                //     ),
                //   ),
                // );
                print(books[index]);
                print(books[index].id);
              },
              onLongPress: () async {
                await DatabaseManager.deleteBook(books[index].id!);
                setState(() {
                  books.removeAt(index);
                });
              },
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 0.7 / 1, // 原始内容的宽高比
                      child: Image(
                        image: FileImage(File(books[index].coverUrl)),
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/no-cover.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    // Image.network(
                    //     'https://picsum.photos/472/700?random=$index',
                    //     fit: BoxFit.contain,
                    //   ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: Text(
                        books[index].name,
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
        onPressed: () async {
          await addBook();
        },
        tooltip: 'Add Book',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future addBook() async {
    final filePickerHelper = FilePickerHelper();
    await filePickerHelper.pickFile();
    getBooks();
  }
}
