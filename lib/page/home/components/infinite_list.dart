import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

class InfiniteListPage extends StatefulWidget {
  const InfiniteListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InfiniteListPageState createState() => _InfiniteListPageState();
}

class _InfiniteListPageState extends State<InfiniteListPage> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildRow(WordPair pair) {
    return Card(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(16.0),
            child: Image.network(
              'https://m.media-amazon.com/images/I/41FaQSrrZjL.jpg',
              width: 80.0,
              height: 80.0,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Author: John Doe',
                  style: TextStyle(fontSize: 14.0),
                ),
                const Text(
                  'Published: 2021',
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return const Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }

        return _buildRow(_suggestions[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSuggestions(),
    );
  }
}
