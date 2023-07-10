/*
 * @Author: LiZhi
 * @Date: 2023-07-10 23:28:00
 * @Description: 图书对象 
 * @Import: import 'model/book_model.dart';
 */
class Book {
  int? id; // 将类型更改为int?

  String name;
  String author;
  String coverUrl;
  String additionalInfo;

  Book({
    required this.name,
    required this.author,
    required this.coverUrl,
    required this.additionalInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'author': author,
      'coverUrl': coverUrl,
      'additionalInfo': additionalInfo,
    };
  }

  static Book fromMap(Map<String, dynamic> map) {
    return Book(
      name: map['name'],
      author: map['author'],
      coverUrl: map['coverUrl'],
      additionalInfo: map['additionalInfo'],
    );
  }
  @override
  String toString() {
    return 'Book: id=$id, name=$name, author=$author, coverUrl=$coverUrl, additionalInfo=$additionalInfo';
  }
}
