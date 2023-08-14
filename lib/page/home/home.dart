import 'package:flutter/material.dart';
import 'components/seach.dart';
import 'components/infinite_list.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:path_provider/path_provider.dart';
import 'package:epub_view/epub_view.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

// import '../../common/test.dart';
import '../../common/qqq.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  late EpubController _controller;

  @override
  Widget build(BuildContext context) {
    PermissionUtils.requestStoragePermission();
    _controller = EpubController(
        // Load document
        document: EpubDocument.openAsset(
            'sdcard/Books/The.epub'));
    return MaterialApp(
      title: 'Hello, World!',
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(14.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    const Expanded(child: SearchBox()),
                    IconButton(
                      icon: const Icon(Icons.add),
                      splashRadius: 20.0,
                      onPressed: () {
                        // _readBook();
                        readFile();
                        // setPermission();
                        // initState();
                      },
                    ),
                  ],
                ),
              ),
            )),
        body: EpubView(
          controller: _controller,
        ),
      ),
    );
  }

  void _readBook() async {
    var sdCardPath = await getExternalStorageDirectory();
    var sd = await getApplicationDocumentsDirectory();
    var sdC = await getApplicationSupportDirectory();
    // var list = await getDirectoryPath('sdcard');
    // 获取sdcard路径
    var systemTempDir = Directory('sdcard');
    // final Directory sdCardDir = await getExternalStorageDirectory();
    // final Directory root = findRoot(await getApplicationDocumentsDirectory());
    // File file = File('assets/Books/book.epub');

    print('1111');
    print(sdCardPath?.path);
    print(sd?.path);
    print(sdC?.path);
    print(systemTempDir);
  }

  readFile() async {
    print('读取文件');
    await Permission.storage.request();
    final file = File('sdcard/Books/data.txt');
    String contents = await file.readAsString();
    print(contents);
  }

  setPermission() async {
    var list = await getDirectoryPath('sdcard');
    debugPrint('list===$list', wrapWidth: 1024);
  }

  //读取SDK中图片、视频文件的路径（异步读取）
  getDirectoryPath(rootName) async {
    print('读取SD卡');
    //'sdcard/Android/data'没有权限读取 排除它
    var list = [];
    try {
      var systemTempDir = Directory(rootName);
      Stream<FileSystemEntity> dirsFileList =
          systemTempDir.list(recursive: false, followLinks: false);

      //一级目录,排除sdcard/Android
      await for (FileSystemEntity entity in dirsFileList) {
        final path = entity.path;
        debugPrint('path===$path');
        //判断是否有二级路由
        FileSystemEntityType type = FileSystemEntity.typeSync(path);
        if (!path.startsWith('sdcard/Android')) {
          if (type == FileSystemEntityType.directory) {
            //有二级目录
            var newList = await getDirectoryPath(path);
            list = [...list, ...newList];
          } else {}
        }
      }
    } catch (e) {
      debugPrint('e===$e');
    }
    return list;
  }
}
