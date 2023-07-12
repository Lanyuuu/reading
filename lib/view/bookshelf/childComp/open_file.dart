import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '/store/book_manager.dart';
import '/model/book_model.dart';

class FileHandler{

  /// @description: 添加图书
  Future<dynamic> addBook() async {
    final books = await DatabaseManager.getAllBooks();
    print(books);
    return books;
  }

  /// @description: 选择文件
  Future<dynamic> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null) {
      await processTheFile(result.files.single.path);
    }
  }

  /// @description: 处理文件
  Future<dynamic> processTheFile(filePath) async {
    try {
      File file = File(filePath);

      final bytes = await file.readAsBytes();
      String localPath = await _localfilePath();
      final directory = Directory('$localPath/bookshelf');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final bookFile = File('${directory.path}/${file.path.split('/').last}');
      bookFile.writeAsBytesSync(bytes);
      Archive archive = ZipDecoder().decodeBytes(bytes);
      await _saveFile(archive, directory);
    } catch (e) {
      print(e);
    }
  }

  /// @description: 保存文件
  Future<dynamic> _saveFile(archive, directory) async {
    try {
      for (ArchiveFile file in archive) {
        final filePath = '${directory.path}/${file.name}';
        if (file.isFile) {
          final data = file.content as List<int>;
          File(filePath).writeAsBytesSync(data, flush: true);
          if (filePath.endsWith('.opf')) {
            final opfFile = File(filePath);
            await _analysisOpf(opfFile, directory);
          }
        } else {
          Directory(filePath).createSync(recursive: true);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> _analysisOpf(opfFile, directory) async {
    final contents = opfFile.readAsStringSync();

    // 解析 OPF 文件
    final document = XmlDocument.parse(contents);
    final package = document.getElement('package');
    final metadata = package?.getElement('metadata');
  }

  Future<dynamic> getTitle(opfFile, directory) async {
    final title = metadata?.getElement('dc:title')?.text;
  }

  Future<dynamic> getAuthor(opfFile, directory) async {
    final author = metadata?.getElement('dc:creator')?.text;
  }

  Future<dynamic> getCoverHref(opfFile, directory) async {
    final cover = document
        .findAllElements('item')
        .firstWhere((item) => item.getAttribute('media-type') == 'image/jpeg');
    final coverHref = cover.getAttribute('href');
  }

  Future<dynamic> getChapters(opfFile, directory) async {
    // 提取目录信息
    final manifest = package?.getElement('manifest');
    final spine = package?.getElement('spine');

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
  }

  Future<dynamic> getTitle(opfFile, directory) async {
    final title = metadata?.getElement('dc:title')?.text;
  }

  Future _writeDatabase() {
    final book = Book(
      name: title ?? 'Unknown',
      author: author ?? 'Unknown',
      coverUrl: coverHref != null ? '${directory.path}/$coverHref' : 'Unknown',
      additionalInfo: 'A comprehensive guide to Flutter development.',
      chapters: chapters ?? 'Unknown',
    );
    await DatabaseManager.addBook(book);
    final books = await DatabaseManager.getAllBooks();
    print(books);
    return books;
  }

  /// 获取文档目录
  Future<String> _localfilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  
}



