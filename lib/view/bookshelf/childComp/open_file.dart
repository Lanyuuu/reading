import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '/store/book_manager.dart';
import '/model/book_model.dart';

Future<dynamic> pickFile() async {
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
      final cover = document
      .findAllElements('item')
      .firstWhere((item) => item.getAttribute('media-type') == 'image/jpeg');
      final coverHref = cover.getAttribute('href');

      // 提取目录信息
      final manifest = package?.getElement('manifest');
      final spine = package?.getElement('spine');
      final toc =
          spine?.getElement('itemref[@idref="toc"]')?.getAttribute('idref');

      final items = manifest?.findAllElements('item');
      final acontents = spine
          ?.findAllElements('itemref')
          .map((itemref) => itemref.getAttribute('idref'))
          .map((idref) =>
              items?.firstWhere((item) => item.getAttribute('id') == idref))
          .toList();

      print('Title: $title');
      print('Author: $author');
      print('Cover: $coverHref');
      print('TOC: $toc');
      print('Contents: $acontents');


      final chapters = spine
        ?.findAllElements('itemref')
        .map((itemref) => itemref.getAttribute('idref'))
        .map((idref) =>
            items?.firstWhere((item) => item.getAttribute('id') == idref))
        .where((item) =>
            item?.getAttribute('media-type') == 'application/xhtml+xml' &&
            item?.getAttribute('href')?.endsWith('.html') == true)
        .map((item) => {'${directory.path}/${item?.getAttribute('href')}'})
        .toList()
        .join(']');

      final book = Book(
        name: title??'Unknown',
        author: author??'Unknown',
        coverUrl: coverHref != null?'${directory.path}/$coverHref':'Unknown',
        additionalInfo: 'A comprehensive guide to Flutter development.',
        chapters: chapters??'Unknown',
      );

      await DatabaseManager.addBook(book);
      final books = await DatabaseManager.getAllBooks();
      print(books);
      return books;
    } catch (e) {
      print(e);
    }
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





