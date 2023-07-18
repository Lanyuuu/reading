import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '/store/book_manager.dart';
import '/model/book_model.dart';

class FilePickerHelper {
  Future<Object> pickFile() async {
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

        await _extractFiles(bytes, directory);
        final metadata = await _parseMetadata(directory);
        final chapters = await _parseChapters(directory);

        final book = Book(
          name: metadata['title']??'Unknown',
          author: metadata['author']??'Unknown',
          coverUrl: metadata['cover'] != null?'${directory.path}/${metadata['cover']}':'Unknown',
          additionalInfo: 'A comprehensive guide to Flutter development.',
          chapters: chapters??'Unknown',
        );

        await DatabaseManager.addBook(book);
        return true;
      } catch (e) {
        print(e);
      }
    }
    return [];
  }

  /// 获取文档目录
  Future _localfilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  /// 解压缩文件
  Future<void> _extractFiles(List<int> bytes, Directory directory) async {
    Archive archive = ZipDecoder().decodeBytes(bytes);
    await Future.forEach(archive.files, (file) async {
      final filename = file.name;
      final filePath = '${directory.path}/$filename';
      if (file.isFile) {
        final data = file.content as List<int>;
        File(filePath).writeAsBytesSync(data, flush: true);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    });
  }

  /// 解析元数据
  Future<Map<String, String?>> _parseMetadata(Directory directory) async {
    final opfFile = _findOpfFile(directory);
    final contents = opfFile.readAsStringSync();
    final document = XmlDocument.parse(contents);
    final package = document.getElement('package');
    final metadata = package?.getElement('metadata');
    final title = metadata?.getElement('dc:title')?.text;
    final author = metadata?.getElement('dc:creator')?.text;
    final cover = document
        .findAllElements('item')
        .firstWhere((item) => item.getAttribute('media-type') == 'image/jpeg');
    final coverHref = cover.getAttribute('href');
    return {
      'title': title,
      'author': author,
      'cover': coverHref,
    };
  }

  /// 解析章节
  Future<String?> _parseChapters(Directory directory) async {
    final opfFile = _findOpfFile(directory);
    final contents = opfFile.readAsStringSync();
    final document = XmlDocument.parse(contents);
    final package = document.getElement('package');
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
        .where((item) =>
            item?.getAttribute('media-type') == 'application/xhtml+xml' &&
            item?.getAttribute('href')?.endsWith('.html') == true)
        .map((item) => '${directory.path}/${item?.getAttribute('href')}')
        .toList()
        .join(']');
    return acontents;
  }

  /// 查找opf文件
  _findOpfFile(Directory directory) {
    final files = directory.listSync(recursive: true);
    final opfFile = files.firstWhere((file) => file.path.endsWith('.opf'));
    return opfFile;
  }
}
