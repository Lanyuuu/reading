import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:epub_view/epub_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:epubx/epubx.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

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
        List<int> abytes = await bookFile.readAsBytes();
        Archive archive = ZipDecoder().decodeBytes(bytes);
        print(archive);
        for (ArchiveFile file in archive) {
          final filename = file.name;
          final data = file.content as List<int>;
          print('${directory.path}$filename');
          final filePath = '${directory.path}/${file.name}';
          if (file.isFile) {
            final data = file.content as List<int>;
            File(filePath).writeAsBytesSync(data, flush: true);
          } else {
            Directory(filePath).createSync(recursive: true);
          }
        }

        final opfFile = File('${directory.path}/metadata.opf');
        final contents = opfFile.readAsStringSync();

        // 解析 OPF 文件
        final document = XmlDocument.parse(contents);
        final package = document.getElement('package');
        
        // 提取元数据信息
        final metadata = package?.getElement('metadata');
        final title = metadata?.getElement('dc:title')?.text;
        final author = metadata?.getElement('dc:creator')?.text;
        final cover = metadata?.getElement('meta[@name="cover"]')?.getAttribute('content');
        
        // 提取目录信息
        final manifest = package?.getElement('manifest');
        final spine = package?.getElement('spine');
        final toc = spine?.getElement('itemref[@idref="toc"]')?.getAttribute('idref');
        
        final items = manifest?.findAllElements('item');
        final acontents = spine?.findAllElements('itemref')
                            .map((itemref) => itemref.getAttribute('idref'))
                            .map((idref) => items?.firstWhere((item) => item.getAttribute('id') == idref))
                            .toList();

        print('Title: $title');
        print('Author: $author');
        print('Cover: $cover');
        print('TOC: $toc');
        print('Contents: $acontents');

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
