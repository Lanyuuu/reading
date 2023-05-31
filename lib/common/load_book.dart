import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class BookshelfWidget extends StatefulWidget {
  const BookshelfWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BookshelfWidgetState createState() => _BookshelfWidgetState();
}

class _BookshelfWidgetState extends State<BookshelfWidget> {
  final List<File> _books = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addBook,
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _books.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(_books[index].path),
                onTap: () {
                  _openBook(_books[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _addBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      await _copyBook(file);
      setState(() {
        _books.add(file);
      });
    }
  }

  void _openBook(File book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => EpubView(
          filePath: book.path, controller: null,
        ),
      ),
    );
  }

  Future<void> _copyBook(File file) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String fileName = basename(file.path);
    String newPath = '$appDocPath/$fileName';
    await file.copy(newPath);
  }
}
