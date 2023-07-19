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

  @override
  void initState() {
    super.initState();
    parseHtml();
  }

  void parseHtml() {
    try {
      final List<String> chapters = widget.chapter.split("]");
      print("第一章: ${chapters[0]}");
      final file = File(chapters[1]);
      setState(() {
        htmlBody = file.readAsStringSync();
      });
    } catch (e) {
      htmlBody = "<p>获取不到章节</p>";
      print(e);
    }
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
          margin: const EdgeInsets.only(bottom: 10),
          child: CostomWidget(text: node.text),
        );
      case 'em':
        return Transform(
          transform: Matrix4.skewX(-0.2), // 这里的0.2表示横向倾斜弧度，可以根据需要调整倾斜程度
          child: Text(
            node.text, // 要倾斜的文本
            style: const TextStyle(fontSize: 18),
          ),
        );
      default:
        return Text(
          node.text,
          style: const TextStyle(
            fontSize: 18,
          ),
        );
    }
  }

  List<Widget> generateChildren(dom.Document document) {
    
    List<Widget> childElements = [];
    final dom.Element body = document.body!;

    void traverse(dom.Element currentElement) {
      for (var node in currentElement.nodes) {
        if (node is dom.Element) {
          if(node.text != "") {
            childElements.add(getAllChildElements(node));
          }
          
          traverse(node); // 递归调用遍历当前节点的子节点
        }
        childElements.add(SizedBox.shrink());
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
