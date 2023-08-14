// import 'dart:io';
// import 'package:epub/epub.dart';

// Future<EpubBook> readEpub(String filePath) async {
//   File file = File(filePath);

//   // Parse the EPUB file to fix TOC ID
//   EpubParser parser = EpubParser();
//   EpubBookRef bookRef = await parser.parseBook(file.readAsStringSync());
//   bookRef.TOC.forEach((item) {
//     if (item.Id.isEmpty) {
//       item.Id = 'toc-${item.Href.hashCode}';
//     }
//   });

//   // Read the EPUB file
//   EpubReader reader = EpubReader();
//   EpubBook book = await reader.readBook(file.readAsBytesSync());

//   return book;
// }