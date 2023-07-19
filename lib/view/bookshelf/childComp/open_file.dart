import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '/store/book_manager.dart';
import '/model/book_model.dart';

class FilePickerHelper {
  final String _extension = 'epub';
  final String _additionalInfo =
      'A comprehensive guide to Flutter development.';

  Future<Object> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [_extension],
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

        final bookDirectory = Directory(
            '${directory.path}/${_getFileNameWithoutExtension(file)}');
        if (!bookDirectory.existsSync()) {
          bookDirectory.createSync(recursive: true);
        }

        final bookFile =
            File('${bookDirectory.path}/${file.path.split('/').last}');
        bookFile.writeAsBytesSync(bytes);

        await _extractFiles(bytes, bookDirectory);
        final metadata = await _parseMetadataOrChapters(bookDirectory, true);
        final chapters = await _parseMetadataOrChapters(bookDirectory, false);
        final coverUrl = await _findCover(bookDirectory);

        final book = Book(
          name: metadata['title'] ?? 'Unknown',
          author: metadata['author'] ?? 'Unknown',
          coverUrl: coverUrl,
          additionalInfo: _additionalInfo,
          chapters: chapters ?? 'Unknown',
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
    print("解压缩文件");
    Archive archive = ZipDecoder().decodeBytes(bytes);
    await Future.forEach(archive.files, (file) async {
      final filename = file.name;
      final filePath = '${directory.path}/$filename';
      if (file.isFile) {
        final data = file.content;
        try {
          final file = File(filePath);
          if (!file.existsSync()) {
            file.createSync(recursive: true);
          }
          file.writeAsBytesSync(data, flush: true);
        } catch (e) {
          print('Error writing file: $e');
        }
      } else {
        final dir = Directory(filePath);
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
      }
    });
  }

  /// 解析元数据或章节
  Future<dynamic> _parseMetadataOrChapters(
      Directory directory, bool isMetadata) async {
    print(isMetadata ? "解析元数据" : "解析章节");
    final opfFile = _findOpfFile(directory);
    String directoryPath = opfFile.path.substring(0, opfFile.path.lastIndexOf('/'));
    final contents = opfFile.readAsStringSync();
    final document = XmlDocument.parse(contents);
    final package = document.getElement('package');
    final metadata = package?.getElement('metadata');
    final title = metadata?.getElement('dc:title')?.text;
    print(title);
    final author = metadata?.getElement('dc:creator')?.text;
    print(author);
    if (isMetadata) {
      return {
        'title': title,
        'author': author,
      };
    } else {
      final manifest = package?.getElement('manifest');
      final spine = package?.getElement('spine');
      final items = manifest?.findAllElements('item');
      final acontents = spine
          ?.findAllElements('itemref')
          .map((itemref) => itemref.getAttribute('idref'))
          .map((idref) =>
              items?.firstWhere((item) => item.getAttribute('id') == idref))
          .where((item) =>
              item?.getAttribute('media-type') == 'application/xhtml+xml' &&
              item?.getAttribute('href')?.endsWith('.html') == true)
          .map((item) => '$directoryPath/${item?.getAttribute('href')}')
          .toList()
          .join(']');
      return acontents;
    }
  }

  /// 查找opf文件
  _findOpfFile(Directory directory) {
    print("查找opf文件");
    final files = directory.listSync(recursive: true);
    final opfFile = files.firstWhere((file) => file.path.endsWith('.opf'));
    print(1111);
    return opfFile;
  }

  /// 查找封面文件
  _findCoverFile(Directory directory) {
    print("查找封面文件");
    final files = directory.listSync(recursive: true);
    final coverFile = files.firstWhere((file) => file.path.contains('cover'));
    return coverFile != null ? File(coverFile.path) : null;
  }

  /// 查找封面图片
  Future<String> _findCover(Directory directory) async {
    print("查找封面图片");
    try {
      final opfFile = _findOpfFile(directory);
      String directoryPath = opfFile.path.substring(0, opfFile.path.lastIndexOf('/'));
      final contents = opfFile.readAsStringSync();
      final document = XmlDocument.parse(contents);
      final package = document.getElement('package');
      final metadata = package?.getElement('metadata');
      final cover = metadata
          ?.findAllElements('meta')
          .firstWhere((meta) => meta.getAttribute('name') == 'cover');
      final coverId = cover?.getAttribute('content');
      final manifest = package?.getElement('manifest');
      final items = manifest?.findAllElements('item');
      final coverItem =
          items?.firstWhere((item) => item.getAttribute('id') == coverId);
      final coverHref = coverItem?.getAttribute('href');
      return coverHref != null ? '$directoryPath/$coverHref' : "";
    } catch (e) {
      final coverFile = _findCoverFile(directory);
      return coverFile?.path ?? "";
    }
  }

  /// 获取不带扩展名的文件名
  String _getFileNameWithoutExtension(File file) {
    return file.path.split('/').last.split('.').first.split('(').first;
  }
}
