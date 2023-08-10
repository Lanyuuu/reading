import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class ReadingPage extends StatefulWidget {
  final String chapter; // 新增章节参数

  const ReadingPage({Key? key, required this.chapter}) : super(key: key);

  @override
  ReadingPageMain createState() => ReadingPageMain();
}

class ReadingPageMain extends State<ReadingPage> {
  String htmlBody = "";
  var chapterIndex = 1;
  List<Widget> childElements = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingNextChapter = false;

  @override
  void initState() {
    super.initState();
    parseHtml();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // 滚动到底部，加载下一章
      if (!_isLoadingNextChapter) {
        setState(() {
          _isLoadingNextChapter = true;
        });
        loadNextChapter().then((_) {
          setState(() {
            _isLoadingNextChapter = false;
          });
        });
      }
    }
  }

  void parseHtml() {
    try {
      final List<String> chapters = widget.chapter.split("]");
      print("第一章: ${chapters[chapterIndex]}");
      final file = File(chapters[chapterIndex]);
      setState(() {
        htmlBody = file.readAsStringSync();
        chapterIndex++;
      });
    } catch (e) {
      htmlBody = "<p>获取不到章节</p>";
      print(e);
    }
  }

  Future<void> loadNextChapter() async {
    String nextHtml = "";
    try {
      final List<String> chapters = widget.chapter.split("]");
      final file = File(chapters[chapterIndex]);
      nextHtml = file.readAsStringSync();
      setState(() {
        chapterIndex++;
      });
    } catch (e) {
      nextHtml = "<p>获取不到章节</p>";
      print(e);
    }

    final dom.Document document = parser.parse(nextHtml);
    generateChildren(document);
  }

  @override
  Widget build(BuildContext context) {
    final dom.Document document = parser.parse(htmlBody);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML Viewer'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: generateChildren(document),
          ),
        ),
      ),
    );
  }

  Widget getAllChildElements(dom.Element node) {
    print(node.localName);
    switch (node.localName) {
      case 'p':
        return Container(
          margin: const EdgeInsets.only(bottom: 1),
          child: CostomWidget(text: node.text),
        );
      case 'div':
        return Container(
          margin: const EdgeInsets.only(bottom: 1),
          child: CostomWidget(text: node.text),
        );
      case 'em':
        return Text(
          node.text,
          style: const TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        );
      default:
        return Text(
          node.text,
          style: const TextStyle(
            fontSize: 10,
          ),
        );
    }
  }

  List<Widget> generateChildren(dom.Document document) {
    final dom.Element body = document.body!;

    void traverse(dom.Element currentElement) {
      for (var node in currentElement.nodes) {
        // print(node.children.length);
        if (node is dom.Element) {
          // print("type: ${node.innerHtml}");
          if (node.text != "") {
            childElements.add(getAllChildElements(node));
          }
          // print(node.hasChildNodes());

          // traverse(node); // 递归调用遍历当前节点的子节点
        }
        childElements.add(const SizedBox.shrink());
      }
    }

    traverse(body);
    return childElements;
  }
}

class CostomWidget extends StatefulWidget {
  final String text;

  const CostomWidget({Key? key, required this.text}) : super(key: key);

  @override
  CostomWidgetP createState() => CostomWidgetP();
}

class CostomWidgetP extends State<CostomWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  late FlutterTts flutterTts;
  String? _newVoiceText;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    flutterTts = FlutterTts();
    setTtsLanguage();
    _textEditingController.text = "      ${widget.text}";
    // 如果words数组的每个元素有开头和结尾有非英文字符, 则需要再次分割
    return SelectableText(
      _textEditingController.text,
      onTap: () {
        setState(() {
          // _backgroundColorList[index] = Colors.yellow;
        });
      },
      style: const TextStyle(
        fontSize: 18,
        // 上下行距
        height: 1.5,
      ),
      toolbarOptions: const ToolbarOptions(
        copy: false,
        selectAll: false,
        cut: false,
        paste: false,
      ),
      onSelectionChanged: (selection, cause) {
        if (cause == SelectionChangedCause.longPress) {
          print(selection.baseOffset);
          print(selection.extentOffset);
          print(selection.textInside(_textEditingController.text));
          print(selection.textAfter(_textEditingController.text));
          print(selection.textBefore(_textEditingController.text));
        } else if (cause == SelectionChangedCause.tap) {
          print(selection);
          print(selection.baseOffset);
          print(selection.extentOffset);
          print(selection.textInside(_textEditingController.text));

          // print(selection.textBefore(_textEditingController.text));
          // print(selection.textAfter(_textEditingController.text));
          final words1 =
              selection.textBefore(_textEditingController.text).split(" ");
          final words2 =
              selection.textAfter(_textEditingController.text).split(" ");

          // 取words1的最后一个元素
          final word1 = words1[words1.length - 1];
          // 取words2的第一个元素
          final word2 = words2[0];
          _newVoiceText = word1 + word2;
          print(_newVoiceText);
          _speak();
          makeTranslateRequest(_newVoiceText);
        }
      },
    );
  }

  Future _speak() async {
    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future<void> setTtsLanguage() async {
    await flutterTts.setLanguage('en-US'); // 设置为英文（美国）
    // await flutterTts.setLanguage('zh-CN'); // 设置为中文（中国）
    // 其他语言和区域代码可根据需要进行设置
  }

  void makeTranslateRequest(str) async {
    var dio = Dio();

    var url = 'https://fanyi-api.baidu.com/api/trans/vip/translate';
    var appid = '20200213000383360'; // 替换为您的百度翻译 API App ID
    var secretKey = '9IIh4CY5zryzv1jMRY6s'; // 替换为您的百度翻译 API 密钥

    var queryParams = {
      'q': str,
      'from': 'en',
      'to': 'zh',
      'appid': appid,
      'salt': DateTime.now().millisecondsSinceEpoch.toString(),
      'sign': '', // 将在下面计算并设置
      'dict': '1'
    };

    // 计算签名并设置到查询参数中
    var sign =
        generateSign(queryParams['q']!, queryParams['salt']!, appid, secretKey);
    queryParams['sign'] = sign;

    try {
      var response = await dio.get(url, queryParameters: queryParams);

      if (response.statusCode == 200) {
        // 请求成功，处理响应数据
        print(response.data);
        print(response.data['trans_result'][0]['dst']);
      } else {
        // 请求失败
        print('请求失败：${response.statusCode}');
      }
    } catch (e) {
      // 请求异常
      print('请求异常：$e');
    }
  }

  String generateSign(
      String query, String salt, String appid, String secretKey) {
    var sign = appid + query + salt + secretKey;
    return md5.convert(utf8.encode(sign)).toString();
  }
}
