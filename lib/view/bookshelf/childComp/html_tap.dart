import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class MyHtmlView extends StatelessWidget {
  final String html;

  const MyHtmlView({Key? key, required this.html}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 在这里添加你的点击事件处理代码
        print('HTML view tapped!');
      },
      child: Html(
        data: html,
      ),
    );
  }
}
