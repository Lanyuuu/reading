import 'package:flutter/material.dart';
import 'components/seach.dart';
import 'components/infinite_list.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:simple_permissions/simple_permissions.dart';//记得加上这句话
import 'package:path_provider/path_provider.dart';
import 'package:epub_view/epub_view.dart';

// import '../../common/test.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      // TODO: 添加本地 epub 书籍的逻辑
                      // initState();
                    },
                  ),
                ],
              ),
            ),
          )),
        body: const InfiniteListPage(),
      ),
    );
  }
}

//读取文件方法
readData() async {
  try {
    //申请读文件的权限
    var permission =
    SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    var sdCardPath = getExternalStorageDirectory();
    //当获取到路径的时候
    sdCardPath.then((filePath) {
      //获得读取文件权限
      permission.then((permission_status) async {
        //获取文件内容
        // var data = await File(filePath.path + "/flutter.txt").readAsString();
      });
    });
  // ignore: empty_catches
  } catch (e) {}
}

