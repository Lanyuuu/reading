// import 'package:flutter/material.dart';
// // ignore: import_of_legacy_library_into_null_safe
// import 'package:flutter_file_manager/flutter_file_manager.dart';

// class OpenFilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('打开文件列表'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text('选择文件'),
//           onPressed: () async {
//             final files = await FileManager.pickFiles(
//               context,
//               fileExtension: 'pdf', // 可选：限制文件类型
//             );
//             if (files != null && files.length > 0) {
//               print('已选择文件：${files[0].path}');
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
