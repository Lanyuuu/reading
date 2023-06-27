import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);
  final String html = '''
    <h1>HTML Parsing Example</h1>
    <p>This is an example of parsing HTML in Flutter.</p>
  ''';

  @override
  Widget build(BuildContext context) {
    final htmls = _loadHtmlFromAssets();
    final dom.Document document = parser.parse(htmls);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML Viewer'),
      ),
      // body: ListView.builder(
      //   itemBuilder: (BuildContext context, int index) {
      //     return ListTile(
      //       title: MysWidget()
      //     );
      //   },
      // )
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: SingleChildScrollView(
        child: Column(
          children: document.body!.nodes.map((node) {
            node.text = node.text?.replaceAll('\n', '');
            if (node is dom.Element) {
              switch (node.localName) {
                case 'p':
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: MyWidget(text: node.text),
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
            return SizedBox.shrink();
          }).toList(),
        ),
      ),
      ),

    );
  }

  String _loadHtmlFromAssets() {
    const String htmlString = """
      <p class="1Text">He was an old man who fished alone in a skiff in the Gulf Stream 
and he had gone eighty-four days now without taking a fish. In the first forty 
days a boy had been with him. But after forty days without a fish the boy’s 
parents had told him that the old man was now definitely and finally salao, 
which is the worst form of unlucky, and the boy had gone at their orders in 
another boat which caught three good fish the first week. It made the boy sad 
to see the old man come in each day with his skiff empty and he always went 
down to help him carry either the coiled lines or the gaff and harpoon and the 
sail that was furled around the mast. The sail was patched with flour sacks 
and, furled, it looked like the flag of permanent defeat. The old man was thin 
and gaunt with deep wrinkles in the back of his neck. The brown blotches of the 
benevolent skin cancer the sun brings from its [9] reflection on the tropic sea 
were on his cheeks. The blotches ran well down the sides of his face and his 
hands had the deep-creased scars from handling heavy fish on the cords. But 
none of these scars were fresh. They were as old as erosions in a fishless 
desert. Everything about him was old except his eyes and they were the same 
color as the sea and were cheerful and undefeated.</p> 
 
<p class="1Text">“Santiago,” the boy said to him as they climbed the bank from 
where the skiff was hauled up. “I could go with you again. We’ve made some 
money.”</p> 
 
<p class="1Text">The old man had taught the boy to fish and the boy loved him.</p> 
 
<p class="1Text">“No,” the old man said. “You’re with a lucky boat. Stay with 
them.”</p> 
      """;
    return htmlString;
  }
}


class MyWidget extends StatefulWidget {
  final String text;

  const MyWidget({Key? key, required this.text}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<Color> _backgroundColorList = [];
  List<String?> _words = [];

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(" ");
    _backgroundColorList = List.filled(_words.length, Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    // 如果words数组的每个元素有开头和结尾有非英文字符, 则需要再次分割
    return Wrap(
      runSpacing: 10,
      children: List.generate(_words.length, (index) {
        // print(words[index]);
        return Tooltip(
          message: _words[index],
          preferBelow: false,
          child: Text(
            '${_words[index]} ',
            style: const TextStyle(
              fontSize: 18,
            ),
          )
        );
      }),
    );
  }

  // 字符分割
  List<String?> _splitWords(String word) {
    print(word);
    final pattern = RegExp(r'(\b[a-zA-Z]+\b|[^\s]+)');

    final words = pattern.allMatches(word).map((match) => match.group(0)).toList();

    print(words);
    return words;
    // final List<String> words = [];
    // final List<String> chars = word.split('');
    // String temp = '';
    // for (int i = 0; i < chars.length; i++) {
    //   if (RegExp(r'[a-zA-Z]').hasMatch(chars[i])) {
    //     temp += chars[i];
    //   } else {
    //     if (temp.isNotEmpty) {
    //       words.add(temp);
    //       temp = '';
    //     }
    //     words.add(chars[i]);
    //   }
    // }
    // return words;
  }
}
