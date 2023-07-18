import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '/store/book_manager.dart';
import '/model/book_model.dart';

class FileHandler{
  static XmlDocument? _document;
  static dynamic _package;
  static dynamic _directory;


  /// @description: 添加图书
  static Future<dynamic> addBook() async {
    print(1111);
    final file = await processTheFile(await pickFile());
    final bookFile = await _analysisOpf(await _saveFile(file["archive"], _directory));
    final bookInfo = _getBookAllInfo(bookFile, file["directory"]);
    await _writeDatabase(bookInfo);
    final books = await DatabaseManager.getAllBooks();
    print(books);
    return books;
  }

  /// @description: 选择文件
  static Future<dynamic> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );
    if (result != null) {
      return result.files.single.path;
    }
  }

  /// @description: 处理文件
  static Future<dynamic> processTheFile(filePath) async {
    try {
      File file = File(filePath);

      final bytes = await file.readAsBytes();
      String localPath = await _localfilePath();
      _directory = Directory('$localPath/bookshelf');
      if (!_directory.existsSync()) {
        _directory.createSync(recursive: true);
      }

      final bookFile = File('${_directory.path}/${file.path.split('/').last}');
      bookFile.writeAsBytesSync(bytes);
      Archive archive = ZipDecoder().decodeBytes(bytes);
      return {
        "archive": archive
      };
    } catch (e) {
      print(e);
    }
  }

  /// @description: 保存文件
  static Future<File> _saveFile(Archive archive, Directory directory) async {
    File? opfFile;
    try {
      for (ArchiveFile file in archive) {
        final filePath = '${directory.path}/${file.name}';
        if (file.isFile) {
          final data = file.content as List<int>;
          File(filePath).writeAsBytesSync(data, flush: true);
          if (filePath.endsWith('.opf')) {
            opfFile = File(filePath);
          }
        } else {
          Directory(filePath).createSync(recursive: true);
        }
      }
      return opfFile!;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  static Future<dynamic> _analysisOpf(opfFile) async {
    final contents = opfFile.readAsStringSync();

    // 解析 OPF 文件
    _document = XmlDocument.parse(contents);
    _package = _document?.getElement('package');
    final metadata = _package?.getElement('metadata');

    final cover = _document
        ?.findAllElements('item')
        .firstWhere((item) => item.getAttribute('media-type') == 'image/jpeg');
    print(cover);

    final manifest = _package?.getElement('manifest');
    final spine = _package?.getElement('spine');

    final items = manifest?.findAllElements('item');
    final chapters = spine
        ?.findAllElements('itemref')
        .map((itemref) => itemref.getAttribute('idref'))
        .map((idref) =>
            items?.firstWhere((item) => item.getAttribute('id') == idref))
        .where((item) =>
            item?.getAttribute('media-type') == 'application/xhtml+xml' &&
            item?.getAttribute('href')?.endsWith('.html') == true)
        .map((item) => {'${_directory.path}/${item?.getAttribute('href')}'})
        .toList()
        .join(']');
    print(chapters);
  }

  // 获取标题
  static String _getTitle(metadata) {
    return metadata?.getElement('dc:title')?.text;
  }

  // 获取作者
  static String _getAuthor(metadata) {
    return metadata?.getElement('dc:creator')?.text;
  }

  // 获取封面
  static String? _getCoverHref() {
    print(_document);
    final cover = _document
        ?.findAllElements('item')
        .firstWhere((item) => item.getAttribute('media-type') == 'image/jpeg');
    print(cover);
    return cover?.getAttribute('href');
  }

  // 获取章节
  static String _getChapters(directory) {
    // 提取目录信息
    final manifest = _package?.getElement('manifest');
    final spine = _package?.getElement('spine');

    final items = manifest?.findAllElements('item');
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
    return chapters;
  }

  static dynamic _getBookAllInfo(bookFile, directory) {
    return {
      'title': _getTitle(bookFile['metadata']),
      'author': _getAuthor(bookFile['metadata']),
      'coverHref': directory.path + '/' + _getCoverHref(),
      'chapters': _getChapters(directory),
    };
  }

  static Future _writeDatabase(bookInfo) async {
    final book = Book(
      name: bookInfo.title ?? 'Unknown',
      author: bookInfo.author ?? 'Unknown',
      coverUrl: bookInfo.coverHref ?? 'Unknown',
      additionalInfo: 'A comprehensive guide to Flutter development.',
      chapters: bookInfo.chapters ?? 'Unknown',
    );
    print(book);
    await DatabaseManager.addBook(book);
  }

  /// 获取文档目录
  static Future<String> _localfilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

}



