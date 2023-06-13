import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:path_provider/path_provider.dart';

class Book {
  final String title;
  final String author;
  final String filePath;

  Book({required this.title, required this.author, required this.filePath});
}

class Bookshelf extends StatefulWidget {
  const Bookshelf({Key? key}) : super(key: key);

  @override
  _BookshelfState createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  List<Book> _books = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null) {
      try {
        File file = File(result.files.single.path!);

        final bytes = await file.readAsBytes();
        String path = await _localfilePath();
        final directory = Directory('$path/bookshelf');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        final bookFile = File('${directory.path}/${file.path.split('/').last}');
        bookFile.writeAsBytesSync(bytes);

        setState(() {
          _books.add(Book(
            title: file.path.split('/').last,
            author: 'Unknown',
            filePath: '${directory.path}/${file.path.split('/').last}',
          ));
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _openBook(Book book) async {
    EpubController controller = EpubController(
      document: EpubReader.readBook(File(book.filePath).readAsBytesSync()),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EpubView(
          controller: controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookshelf'),
      ),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_books[index].title),
            subtitle: Text(_books[index].author),
            onTap: () async {
              // _localfilePath();
              // // _getEpubInfo();
              // _openBook(_books[index]);
              VocsyEpub.setConfig(
                themeColor: Theme.of(context).primaryColor,
                identifier: "iosBook",
                scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                allowSharing: true,
                enableTts: true,
                nightMode: false,
              );

              // get current locator
              VocsyEpub.locatorStream.listen((locator) {
                print('LOCATOR: $locator');
              });

              VocsyEpub.open(
                _books[index].filePath,
                lastLocation: EpubLocator.fromJson({
                  "bookId": "2239",
                  "href": "/OEBPS/ch06.xhtml",
                  "created": 1539934158390,
                  "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
                }),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        tooltip: 'Add Book',
        child: Icon(Icons.add),
      ),
    );
  }

  // 获取点击的epub文件信息并打印
  void _getEpubInfo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      EpubBook epubBook = await EpubReader.readBook(file.readAsBytesSync());
      print(epubBook.Title);
      print(epubBook.Author);
      print(epubBook.CoverImage);
      // print(epubBook.Content);
      // print(epubBook.Schema);
      // print(epubBook.Chapters);
    }
  }

  /// 获取文档目录
  Future _localfilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  /// 获取文档
  Future<File> _localfile() async {
    String path = await _localfilePath();
    print('$path/settting.txt');
    return new File('$path/settting.txt');
  }

  /// 保存内容到文本
  void _saveFile(String val) async {
    try {
      File file = await _localfile();
      IOSink sink = file.openWrite(mode: FileMode.append);
      sink.write(val);
      sink.close();
    } catch (e) {
      print(e);
    }
  }
}
